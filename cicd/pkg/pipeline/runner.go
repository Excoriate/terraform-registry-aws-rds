package pipeline

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/executor"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/setup"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
)

type RunnerResult struct {
	IsError        bool
	StandardOutput string
	StandardError  string
	Message        string
	// These are optionals. I'm not sure whether to add them in future functionalities :/
	OutputDir string
	Files     []string
}

type Runner interface {
	Start() (*RunnerResult, error)
	CheckPreRequisites() error
	ManageInheritanceFromJobsToActions() error
	PrepareForDaggerRuntime() error
	ExecuteJobs() error
}

// CheckPreRequisites performs the following validations:
// 1. Pipeline has jobs
// 2. Job has actions
// 3. Action has commands to run
func (p *Client) CheckPreRequisites() error {
	if err := ValidatePipelineHasJobs(p); err != nil {
		return err
	}

	for _, job := range p.API.Params.Jobs {
		if err := ValidateJobHasActions(job); err != nil {
			return err
		}
	}

	for _, job := range p.API.Params.Jobs {
		for _, action := range job.API.Params.Actions {
			if err := ValidateActionHasCommandsToRun(action); err != nil {
				return err
			}
		}
	}

	p.Logger.Info("Pipeline is valid")

	return nil
}

// ManageInheritanceFromJobsToActions manages the inheritance of the following parameters:
// Environment variables
// 1. EnvVars from Job to Action if they're passed or set initially on the job level.
// If the actions include the same EnvVar with the same Key,
// the value is overwritten. If the actions include env vars that does not collide with the job's env vars,
// they are added to the action's env vars (merged).
// Directories.
// 1. If the baseDir is set on the job level, it takes precedence over action's baseDirs, and overrides them.
// 2. If the mountDir is set on the job level, it takes precedence over action's mountDirs, and overrides them.
// 3. If the workDir is set on the job level, it takes precedence over action's workDirs, and overrides them.
func (p *Client) ManageInheritanceFromJobsToActions() error {
	if p.API == nil || p.API.Params == nil {
		return fmt.Errorf("pipeline or pipeline parameters are nil")
	}

	// Directories inheritance.
	for _, jobClient := range p.API.Params.Jobs {
		job := jobClient.API
		// Iterate over the actions for this job
		for _, actionClient := range job.Params.Actions {
			action := actionClient.API
			if action == nil || action.Params == nil {
				continue // If action or action parameters are not set, skip to the next
			}

			// Directories
			// Base Directory
			if job.Params.BaseDir != nil && job.Params.BaseDir.AbsolutePath != "" {
				actionClient.API.Params.BaseDir = job.Params.BaseDir
			}

			// Mount Directory
			if job.Params.MountDir != nil && job.Params.MountDir.AbsolutePath != "" {
				actionClient.API.Params.MountDir = job.Params.MountDir
			}

			// Work Directory
			if job.Params.WorkDir != nil && job.Params.WorkDir.AbsolutePath != "" {
				actionClient.API.Params.WorkDir = job.Params.WorkDir
			}
		}
	}

	// Environment variables inheritance.
	for _, jobClient := range p.API.Params.Jobs {
		job := jobClient.API
		for _, actionClient := range job.Params.Actions {
			action := actionClient.API

			// Now the function tries to add the job level EnvVars to the action.
			for k, v := range job.Params.EnvVars {
				if currentValue, found := action.Params.EnvVars[k]; found {
					p.Logger.Warn(fmt.Sprintf("Duplicate environment"+
						" variable key '%s' found in action '%s'. Current"+
						" value '%s' will be used over job value '%s'.",
						k, action.Name, currentValue, v))
					continue
				}
				action.Params.EnvVars[k] = v
			}
		}
	}

	return nil
}

// PrepareForDaggerRuntime sets up the dagger.
// 1. It checks every job's dir, and action's dir, and create a proper Dagger Directory.
// 2. It creates the action's runtime per each action (Container, Client attachment,
// and directories)
func (p *Client) PrepareForDaggerRuntime() error {
	if p.DaggerClient == nil {
		return fmt.Errorf("failed to setup Dagger, Dagger client is nil")
	}

	// Check each job's dirs first.
	for _, job := range p.API.Params.Jobs {
		// TODO: Check if this path is allowed.
		if job.API.Params.BaseDir.DaggerDir != nil {
			p.Logger.Info(fmt.Sprintf("Job %s with id %s has a baseDir with a DaggerDir. Skipping...",
				job.API.Name, job.API.ID))
			continue
		}

		// If the dagger directory isn't set, set it.
		// 1. Base directory
		job.API.Params.BaseDir.DaggerDir, _ = setup.DaggerDir(job.API.Params.BaseDir.
			AbsolutePath, p.DaggerClient)

		// 2. Mount directory
		job.API.Params.MountDir.DaggerDir, _ = setup.DaggerDir(job.API.Params.MountDir.
			AbsolutePath, p.DaggerClient)

		// 3. Work directory
		job.API.Params.WorkDir.DaggerDir, _ = setup.DaggerDir(job.API.Params.WorkDir.
			AbsolutePath, p.DaggerClient)

		// Check each action's dirs.
		for _, action := range job.API.Params.Actions {
			action.API.Params.BaseDir.DaggerDir, _ = setup.DaggerDir(action.API.Params.BaseDir.
				AbsolutePath, p.DaggerClient)

			action.API.Params.MountDir.DaggerDir, _ = setup.DaggerDir(action.API.Params.MountDir.
				AbsolutePath, p.DaggerClient)

			action.API.Params.WorkDir.DaggerDir, _ = setup.DaggerDir(action.API.Params.WorkDir.
				AbsolutePath, p.DaggerClient)

			// Adding the execution runtime configuration for this specific action.
			action.API.Config.ExecutionRuntime = &types.ActionRuntime{
				// FIXME: Instead of just passing the container,
				//  pass the configured container (with mounted dir, and validated entries instead).
				Container: p.DaggerClient.Container().From(action.API.Params.ContainerImage),
				Client:    p.DaggerClient,
				BaseDir:   action.API.Params.BaseDir,
				MountDir:  action.API.Params.MountDir,
				Workdir:   action.API.Params.WorkDir,
				CMDs:      action.API.Params.CMDs,
				// Passing the commands from the 'parameters' to the 'actual runtime'
			}

			// Attaching runtime configuration (dirs, env vars,
			// etc.) to the Container. It returns a ready-to-use container.
			action.API.Config.ExecutionRuntime.ContainerRuntime = setup.
				AttachRuntimeDirsInContainer(action.API.Config.ExecutionRuntime,
					action.API.Config.ExecutionRuntime.Container)
		}
	}

	return nil
}

func (p *Client) ExecuteJobs() error {
	execClient := executor.New(p)
	for _, job := range p.API.Params.Jobs {
		for _, action := range job.API.Params.Actions {
			if err := execClient.ExecuteAction(action); err != nil {
				return err
			}
		}
	}

	return nil
}

func (p *Client) Start() (*RunnerResult, error) {
	if err := p.CheckPreRequisites(); err != nil {
		return nil, err
	}

	if err := p.ManageInheritanceFromJobsToActions(); err != nil {
		return nil, err
	}

	if err := p.PrepareForDaggerRuntime(); err != nil {
		return nil, err
	}

	if err := p.ExecuteJobs(); err != nil {
		return nil, err
	}

	return nil, nil
}
