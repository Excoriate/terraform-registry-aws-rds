package pipeline

import (
	"context"
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/params"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
)

type InitActionOptions struct {
	// Parameters of the action.
	Name     string
	Commands []*WithCommandOptions
	// Dirs (baseDir, mountDir, and workDir)
	WorkDir        string
	BaseDir        string // If it's not passed, it'll resolve to the default working directory.
	MountDir       string
	EnvVars        map[string]string
	ContainerImage string
	DryRun         bool
	DependsOnIDs   []string
	// Configuration of the action.
	IsParallel            bool
	InheritEnvVarsFromJob bool
	// Special option. If the job's workdir is set, then the action's workdir will be relative to the job's workdir.
	ResolveWorkDirRelativeToJobWorkDir bool
}

type InitActionOptionsFunc func(options *InitActionOptions) error

type ActionBuilder struct {
	logger o11y.LoggerInterface
	ctx    context.Context
}

func NewAction(ctx context.Context, logger o11y.LoggerInterface) *ActionBuilder {
	return &ActionBuilder{
		ctx:    ctx,
		logger: logger,
	}
}

func (b *ActionBuilder) Build(opts ...InitActionOptionsFunc) (*types.ActionClient, error) {
	options := &InitActionOptions{}
	for _, opt := range opts {
		if err := opt(options); err != nil {
			return nil, err
		}
	}

	a := &types.ActionClient{
		Logger: b.logger,
		Ctx:    b.ctx,
	}

	if options.BaseDir == "" {
		b.logger.Warn("HostBaseDir is empty. Defaulting to current directory. " +
			"If the 'base directory' is set at the Job level, it'll override this value")
		options.BaseDir = params.IfBaseDirIsEmptyDefaultToCurrent(options.BaseDir)
	}

	// Validating and resolving the base directory
	baseDirBuilt, baseDirErr := GetBaseDir(options.BaseDir)
	if baseDirErr != nil {
		return nil, fmt.Errorf("failed to build action name %s: %w", options.Name, baseDirErr)
	}

	// Validating the mounted directory
	mountDirBuilt, mountDirErr := GetMountDir(&GetMountDirOptions{
		BaseDir:  options.BaseDir,
		MountDir: options.MountDir,
	})

	if mountDirErr != nil {
		return nil, fmt.Errorf("failed to build action name %s: %w", options.Name, mountDirErr)
	}

	// Validating the working directory
	workDirBuilt, workDirErr := GetWorkDir(&GetWorkDirOptions{
		MountDir: options.MountDir,
		WorkDir:  options.WorkDir,
	})

	if workDirErr != nil {
		return nil, fmt.Errorf("failed to build action name %s: %w", options.Name, workDirErr)
	}

	if options.EnvVars == nil {
		options.EnvVars = params.GetDefaultEmptyEnvVars()
	}

	if options.DependsOnIDs == nil {
		options.DependsOnIDs = params.GetDefaultDependenciesOnIDs()
	}

	// Default to return exit code, and an empty command.
	if options.Commands == nil {
		options.Commands = []*WithCommandOptions{
			{
				ReturnStdout:          false,
				ReturnStderr:          false,
				ReturnExitCode:        true,
				commandStructured:     []string{},
				CommandInPlainEnglish: "",
			},
		}
	}

	// Convert to action runtime commands.
	var cmdToRun []*types.ActionCommand
	for _, cmd := range options.Commands {
		cmdToRun = append(cmdToRun, &types.ActionCommand{
			CMDToRun:       cmd.commandStructured,
			ReturnStdout:   cmd.ReturnStdout,
			ReturnStderr:   cmd.ReturnStderr,
			ReturnExitCode: cmd.ReturnExitCode,
		})
	}

	// Action parameters.
	id := params.GenerateID()
	name := options.Name
	envVars := options.EnvVars
	containerImage := options.ContainerImage

	// Action configuration.
	isParallel := options.IsParallel
	inheritEnvVarsFromJob := options.InheritEnvVarsFromJob
	dependsOnIDs := options.DependsOnIDs

	a.API = &types.Action{
		ID:           id,
		Name:         name,
		DependsOnIDs: dependsOnIDs,
		Params: &types.ActionParams{
			BaseDir:        baseDirBuilt,
			WorkDir:        workDirBuilt,
			MountDir:       mountDirBuilt,
			EnvVars:        envVars,
			CMDs:           cmdToRun,
			ContainerImage: containerImage,
		},
		Config: &types.ActionConfig{
			IsParallel:            isParallel,
			InheritEnvVarsFromJob: inheritEnvVarsFromJob,
			ExecutionRuntime:      &types.ActionRuntime{}, // This is filled in later on in the process.
		},
	}

	b.logger.Info(fmt.Sprintf("Action %s created with name: %s", a.API.ID, a.API.Name))

	return a, nil
}

// WithName is an ActionBuilder option that allows you to set the name of the action.
func (b *ActionBuilder) WithName(name string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if name == "" {
			b.logger.Warn("Action name cannot be empty. A random name will be generated.")
			options.Name = params.GetDefaultRandomName()
			return nil
		}

		options.Name = utils.NormaliseStringToLower(name)
		return nil
	}
}

type WithCommandOptions struct {
	ReturnStdout          bool
	ReturnStderr          bool
	ReturnExitCode        bool // Default to true.
	CommandInPlainEnglish string
	commandStructured     []string
}

// WithCommands is an ActionBuilder option that allows you to set the commands of the action.
// It has a precedence order for its return options. ExitCode -> Stdout -> Stderr.
func (b *ActionBuilder) WithCommands(cmdOptions ...*WithCommandOptions) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if len(cmdOptions) == 0 {
			b.logger.Error("There was no command passed. The commands cannot be empty.")
			return fmt.Errorf("there was no command passed. The commands cannot be empty")
		}

		for _, cmdOpt := range cmdOptions {
			if cmdOpt.CommandInPlainEnglish == "" {
				b.logger.Error("The command cannot be empty.")
				return fmt.Errorf("the command cannot be empty")
			}

			structuredCommand, err := utils.GetCommandStructured(cmdOpt.CommandInPlainEnglish)
			if err != nil {
				b.logger.Error("Failed to parse the command.", err)
				return fmt.Errorf("failed to parse the command: %w", err)
			}
			cmdOpt.commandStructured = structuredCommand

			// Add the structured command to the list of commands.
			options.Commands = append(options.Commands, cmdOpt)
			// Handle the return options with the specified precedence.
			if cmdOpt.ReturnExitCode {
				b.logger.Warn("This command will return the exit code. Stdout and Stderr will be ignored.")
				// The code to set the command to return only the exit code should be added here.
			} else if cmdOpt.ReturnStdout {
				b.logger.Warn("This command will return the stdout. Stderr will be ignored.")
				// The code to set the command to return only stdout should be added here.
			} else if cmdOpt.ReturnStderr {
				// The code to set the command to return only stderr should be added here.
			} else {
				b.logger.Info("This command will return the exit code by default.")
				// Default behavior to return exit code should be added here if needed.
			}
		}
		return nil
	}
}

// WithEnvVars is an ActionBuilder option that allows you to set the env vars of the action.
// It takes a map[string]string, which is used to set the env vars.
func (b *ActionBuilder) WithEnvVars(envVars map[string]string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if envVars == nil {
			b.logger.Error("The env vars cannot be nil.")
			return fmt.Errorf("the env vars cannot be nil")
		}

		// CHeck and escape the env vars.
		for key, value := range envVars {
			if key == "" {
				b.logger.Error("The env var key cannot be empty.")
				return fmt.Errorf("the env var key cannot be empty")
			}

			if value == "" {
				b.logger.Error("The env var value cannot be empty.")
				return fmt.Errorf("the env var value cannot be empty")
			}

			// remove double quotes from the value.
			escapedValue := utils.RemoveDoubleQuotes(value)
			envVars[key] = escapedValue
		}

		options.EnvVars = envVars
		return nil
	}
}

// WithContainerImage is an ActionBuilder option that allows you to set the container image of the action.
// It takes a string, which is used to set the container image.
func (b *ActionBuilder) WithContainerImage(containerImage string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if containerImage == "" {
			b.logger.Error("The container image cannot be empty.")
			return fmt.Errorf("the container image cannot be empty")
		}

		options.ContainerImage = containerImage
		return nil
	}
}

// WithDryRun is an ActionBuilder option that allows you to set the dry run of the action.
// It takes a bool, which is used to set the dry run.
func (b *ActionBuilder) WithDryRun(dryRun bool) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		options.DryRun = dryRun
		return nil
	}
}

func (b *ActionBuilder) WithRunInParallel(isParallel bool) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		options.IsParallel = isParallel
		return nil
	}
}

func (b *ActionBuilder) WithInheritEnvVarsFromJob(inheritEnvVarsFromJob bool) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		options.InheritEnvVarsFromJob = inheritEnvVarsFromJob
		return nil
	}
}

func (b *ActionBuilder) WithDependsOnIDs(dependsOnIDs ...string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if dependsOnIDs == nil {
			b.logger.Error("Action depends on IDs cannot be nil")
			return fmt.Errorf("job depends on IDs cannot be nil")
		}

		if len(dependsOnIDs) == 0 {
			b.logger.Warn("Action depends on IDs cannot be empty. Ignoring.")
			return nil
		}

		options.DependsOnIDs = append(options.DependsOnIDs, dependsOnIDs...)
		return nil
	}
}

// WithWorkDir is an ActionBuilder option that allows you to set the workdir of the action.
// It takes a string, which is used to set the workdir.
func (b *ActionBuilder) WithWorkDir(workDir string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if workDir == "" {
			b.logger.Error("The workdir cannot be empty.")
			return fmt.Errorf("the workdir cannot be empty")
		}

		options.WorkDir = workDir
		return nil
	}
}

// WithMountDir is an ActionBuilder option that allows you to set the mountdir of the action.
// It takes a string, which is used to set the mountdir.
func (b *ActionBuilder) WithMountDir(mountDir string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if mountDir == "" {
			b.logger.Error("The mountDir cannot be empty.")
			return fmt.Errorf("the mountDir cannot be empty")
		}

		options.MountDir = mountDir
		return nil
	}
}

// WithBaseDir is an ActionBuilder option that allows you to set the basedir of the action.
// It takes a string, which is used to set the basedir.
func (b *ActionBuilder) WithBaseDir(baseDir string) InitActionOptionsFunc {
	return func(options *InitActionOptions) error {
		if baseDir == "" {
			b.logger.Error("The baseDir cannot be empty.")
			return fmt.Errorf("the baseDir cannot be empty")
		}

		options.BaseDir = baseDir
		return nil
	}
}
