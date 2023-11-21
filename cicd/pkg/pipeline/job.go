package pipeline

import (
	"context"
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/params"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
)

type InitJobOptions struct {
	// Job parameters
	Name    string
	Actions []*types.ActionClient
	EnvVars map[string]string
	// These directories can be overridden at the job level.
	// They'll replace all the values for all the actions it contains.
	BaseDir             string
	MountDir            string
	WorkDir             string
	ContainerImage      string // TODO: Check whether this conflicts, ir enhance how the actions are managing their images.
	OutputArtifactsPath string
	DependsOnIDs        []string
	// Job configuration
	// TODO: Check whether this conflicts or somehow enhances how actions will run.
	RunActionsInParallel bool
	// By default, it's going to be fail-fast.
	FailFastOnTaskError bool
	ContinueOnTaskError bool
}

type InitJobOptionsFunc func(options *InitJobOptions) error

type JobBuilder struct {
	logger o11y.LoggerInterface
	ctx    context.Context
}

func NewJob(ctx context.Context, logger o11y.LoggerInterface) *JobBuilder {
	return &JobBuilder{
		ctx:    ctx,
		logger: logger,
	}
}

func (b *JobBuilder) Build(opts ...InitJobOptionsFunc) (*types.JobClient, error) {
	options := &InitJobOptions{}
	for _, opt := range opts {
		if err := opt(options); err != nil {
			return nil, err
		}
	}

	j := &types.JobClient{
		Logger: b.logger,
		Ctx:    b.ctx,
	}

	if options.BaseDir == "" {
		options.BaseDir = params.IfBaseDirIsEmptyDefaultToCurrent(options.BaseDir)
		b.logger.Warn("Base directory is empty for job %s. Defaulting to current directory.", options.Name)
	}

	baseDirBuilt, baseDirErr := GetBaseDir(options.BaseDir)
	if baseDirErr != nil {
		return nil, fmt.Errorf("failed to validate baseDir: %w", baseDirErr)
	}

	// Validating mount directory
	mountDirBuilt, mountDirErr := GetMountDir(&GetMountDirOptions{
		BaseDir:  options.BaseDir,
		MountDir: options.MountDir,
	})

	if mountDirErr != nil {
		return nil, fmt.Errorf("failed to validate mountDir: %w", mountDirErr)
	}

	// Validating work directory
	workDirBuilt, workDirErr := GetWorkDir(&GetWorkDirOptions{
		MountDir: options.MountDir,
		WorkDir:  options.WorkDir,
	})

	if workDirErr != nil {
		return nil, fmt.Errorf("failed to validate workDir: %w", workDirErr)
	}

	// Managing some defaults
	if options.EnvVars == nil {
		options.EnvVars = params.GetDefaultEmptyEnvVars()
	}

	if options.DependsOnIDs == nil {
		options.DependsOnIDs = params.GetDefaultDependenciesOnIDs()
	}

	if options.OutputArtifactsPath == "" {
		options.OutputArtifactsPath = params.GetDefaultOutputArtifactPath()
	}

	// Job parameters
	id := params.GenerateID()
	name := options.Name
	actions := options.Actions
	envVars := options.EnvVars
	containerImage := options.ContainerImage
	outputArtifactsPath := options.OutputArtifactsPath
	dependsOnIDs := options.DependsOnIDs

	// Job configuration
	runActionsInParallel := options.RunActionsInParallel
	failFastOnTaskError := options.FailFastOnTaskError
	continueOnTaskError := options.ContinueOnTaskError

	j.API = &types.Job{
		ID:           id,
		Name:         name,
		DependsOnIDs: dependsOnIDs,
		Params: &types.JobParams{
			BaseDir:             baseDirBuilt,
			MountDir:            mountDirBuilt,
			WorkDir:             workDirBuilt,
			Actions:             actions,
			EnvVars:             envVars,
			ContainerImage:      containerImage,
			OutputArtifactsPath: outputArtifactsPath,
		},
		Config: &types.JobConfig{
			RunActionsInParallel: runActionsInParallel,
			FailFastOnTaskError:  failFastOnTaskError,
			ContinueOnTaskError:  continueOnTaskError,
		},
	}

	return j, nil
}

// WithActions is a JobBuilder option that allows you to add actions to the job.
// It takes a variadic number of InitActionOptionsFunc, which are used to build
func (b *JobBuilder) WithActions(actionOptions ...*types.ActionClient) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		// if the action does not have a ContainerImage set, and neither the Job, fail.
		for _, action := range actionOptions {
			if action.API.Params.ContainerImage == "" && options.ContainerImage == "" {
				b.logger.Error(fmt.Sprintf("Action %s does not have a ContainerImage set, and neither the Job", action.API.ID))
				return fmt.Errorf("action %s does not have a ContainerImage set, and neither the Job", action.API.ID)
			}

			// If the action has an image, but the job has it also, and they are different, warn that job's takes precedence.
			if action.API.Params.ContainerImage != "" && options.ContainerImage != "" {
				if action.API.Params.ContainerImage != options.ContainerImage {
					b.logger.Warn(fmt.Sprintf("Action %s has a ContainerImage set, but the Job has it also, and they are different. The Job's takes precedence.", action.API.ID))
					action.API.Params.ContainerImage = options.ContainerImage // Override occur.
				}
			}
		}

		options.Actions = append(options.Actions, actionOptions...)
		return nil
	}
}

func (b *JobBuilder) WithName(name string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if name == "" {
			b.logger.Warn("Job name cannot be empty. A random name will be generated.")
			options.Name = params.GetDefaultRandomName()
			return nil
		}

		options.Name = utils.NormaliseStringToLower(name)
		return nil
	}
}

func (b *JobBuilder) WithEnvVars(envVars map[string]string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if envVars == nil {
			b.logger.Error("Job EnvVars cannot be nil")
			return fmt.Errorf("job EnvVars cannot be nil")
		}

		// Check and sanitise the env vars.
		for k, v := range envVars {
			if k == "" || v == "" {
				b.logger.Error("Job EnvVars cannot have empty keys or values.")
				return fmt.Errorf("job EnvVars cannot have empty keys or values")
			}

			escapedValue := utils.RemoveDoubleQuotes(v)
			envVars[k] = escapedValue

			b.logger.Debug(fmt.Sprintf("EnvVar %s=%s", k, escapedValue))
			b.logger.Info(fmt.Sprintf("Added environment variable with key %s", k))
		}

		options.EnvVars = envVars
		return nil
	}
}

func (b *JobBuilder) WithContainerImage(containerImage string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if containerImage == "" {
			b.logger.Warn("Job ContainerImage cannot be empty")
			return fmt.Errorf("job ContainerImage cannot be empty")
		}

		options.ContainerImage = containerImage
		return nil
	}
}

type WithOutputArtifactsPathOptions struct {
	Path             string
	CreateIfNotExist bool
}

func (b *JobBuilder) WithOutputArtifactsPath(o WithOutputArtifactsPathOptions) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if o.Path == "" {
			b.logger.Error("Job OutputArtifactsPath cannot be empty. If it's set, a path should be defined")
			return fmt.Errorf("job OutputArtifactsPath cannot be empty")
		}

		if !o.CreateIfNotExist {
			if err := utils.DirExist(o.Path); err != nil {
				b.logger.Error("Job OutputArtifactsPath does not exist, and the 'CreateIfNotExist' option was not set")
				return fmt.Errorf("job OutputArtifactsPath does not exist, and the 'CreateIfNotExist' option was not set")
			}
		}

		if err := utils.DirExist(o.Path); err != nil {
			if err := utils.CreateDir(o.Path); err != nil {
				b.logger.Error(fmt.Sprintf("Failed to create the directory %s", o.Path), err)
				return fmt.Errorf("failed to create the directory %s: %w", o.Path, err)
			}
		}

		options.OutputArtifactsPath = o.Path
		return nil
	}
}

// WithRunActionsInParallel is a JobBuilder option that allows you to set the run actions in parallel of the job.
// It takes a bool, which is used to set the run actions in parallel.
func (b *JobBuilder) WithRunActionsInParallel(runActionsInParallel bool) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		options.RunActionsInParallel = runActionsInParallel
		return nil
	}
}

// WithFailFastOnTaskError is a JobBuilder option that allows you to set the fail fast on task error of the job.
// It takes a bool, which is used to set the fail fast on task error.
func (b *JobBuilder) WithFailFastOnTaskError(failFastOnTaskError bool) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		options.FailFastOnTaskError = failFastOnTaskError
		return nil
	}
}

// WithContinueOnTaskError is a JobBuilder option that allows you to set the continue on task error of the job.
// It takes a bool, which is used to set the continue on task error.
func (b *JobBuilder) WithContinueOnTaskError(continueOnTaskError bool) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		options.ContinueOnTaskError = continueOnTaskError
		return nil
	}
}

// WithDependsOnIDs is a JobBuilder option that allows you to set the depends on IDs of the job.
// It takes a variadic number of strings, which are used to set the depends on IDs.
func (b *JobBuilder) WithDependsOnIDs(dependsOnIDs ...string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if dependsOnIDs == nil {
			b.logger.Error("Job depends on IDs cannot be nil")
			return fmt.Errorf("job depends on IDs cannot be nil")
		}

		if len(dependsOnIDs) == 0 {
			b.logger.Warn("Job depends on IDs cannot be empty. Ignoring.")
			return nil
		}

		options.DependsOnIDs = append(options.DependsOnIDs, dependsOnIDs...)
		return nil
	}
}

func (b *JobBuilder) WithBaseDir(baseDir string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if baseDir == "" {
			b.logger.Warn("Job HostBaseDir cannot be empty. A random name will be generated.")
			options.BaseDir = params.GetDefaultRandomName()
			return nil
		}

		options.BaseDir = utils.NormaliseStringToLower(baseDir)
		return nil
	}
}

func (b *JobBuilder) WithMountDir(mountDir string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if mountDir == "" {
			b.logger.Warn("Job MountDir cannot be empty. A random name will be generated.")
			options.MountDir = params.GetDefaultRandomName()
			return nil
		}

		options.MountDir = utils.NormaliseStringToLower(mountDir)
		return nil
	}
}

func (b *JobBuilder) WithWorkDir(workDir string) InitJobOptionsFunc {
	return func(options *InitJobOptions) error {
		if workDir == "" {
			b.logger.Warn("Job WorkDir cannot be empty. A random name will be generated.")
			options.WorkDir = params.GetDefaultRandomName()
			return nil
		}

		options.WorkDir = utils.NormaliseStringToLower(workDir)
		return nil
	}
}
