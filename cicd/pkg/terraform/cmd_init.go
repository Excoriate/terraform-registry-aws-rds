package terraform

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/commands"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/errors"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/terradagger"
)

type InitOptions struct {
	// NoColor is a flag to disable colors in terraform output
	NoColor bool
	// BackendConfigFile is the path to the backend config file
	BackendConfigFile string
	// Upgrade is a flag to upgrade the modules and plugins
	Upgrade bool
}

func (o *InitOptions) validate() error {
	if o.BackendConfigFile != "" {
		if err := utils.FileExist(o.BackendConfigFile); err != nil {
			return &errors.ErrTerraformBackendFileIsNotFound{
				BackendFilePath: o.BackendConfigFile,
				ErrWrapped:      nil,
			}
		}
	}

	return nil
}

// Init Configures a 'terraform init' command and runs it.
func Init(td *terradagger.Client, options *Options, initOptions *InitOptions) error {
	if options == nil {
		options = &Options{}
	}

	if initOptions == nil {
		initOptions = &InitOptions{}
	}

	if err := options.validate(); err != nil {
		return &errors.ErrTerraformInitFailedToStart{
			ErrWrapped: err,
			Details:    "the options passed to the terraform command are invalid",
		}
	}

	if err := initOptions.validate(); err != nil {
		return &errors.ErrTerraformInitFailedToStart{
			ErrWrapped: err,
			Details:    "the init options passed to the terraform command are invalid",
		}
	}

	td.Logger.Info("All the options are valid, and the terraform init command can be started.")

	tfCMD := commands.GetTerraformCommand("init", nil)
	tfCMD.OmitBinaryNameInCommand = true

	if initOptions.NoColor {
		td.Logger.Info("The option no-color is set to true")
		tfCMD, _ = commands.AddArgsToCommand(tfCMD, []commands.Args{
			{
				Name:  "no-color",
				Value: "",
			},
		})
	}

	if initOptions.BackendConfigFile != "" {
		td.Logger.Info(fmt.Sprintf("The option backend-config is set to %s", initOptions.BackendConfigFile))
		tfCMD, _ = commands.AddArgsToCommand(tfCMD, []commands.Args{
			{
				Name:  "backend-config",
				Value: initOptions.BackendConfigFile,
			},
		})
	}

	if initOptions.Upgrade {
		td.Logger.Info("The option upgrade is set to true")
		tfCMD, _ = commands.AddArgsToCommand(tfCMD, []commands.Args{
			{
				Name:  "upgrade",
				Value: "",
			},
		})
	}

	tfCMDDagger := commands.ConvertCommandToDaggerFormat(tfCMD)
	tfImage := resolveTerraformImage(options)
	tfVersion := resolveTerraformVersion(options)

	// Configuring the options.
	tdOptions := &terradagger.ClientConfigOptions{
		Image:    tfImage,
		Version:  tfVersion,
		Workdir:  options.TerraformDir,
		MountDir: td.MountDir,
		CMDs:     tfCMDDagger,
	}

	tdOptions.EnvVars = resolveEnvVarsByOptions(options)

	c, err := td.Configure(tdOptions)

	if err != nil {
		return &errors.ErrTerraformInitFailedToStart{
			ErrWrapped: err,
			Details:    "the terraform init command could not be configured",
		}
	}

	// Run the container.
	return td.Run(c)
}
