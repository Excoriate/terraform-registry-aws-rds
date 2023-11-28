package terraform

import (
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/commands"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/errors"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/terradagger"
)

type PlanOptions struct {
	// VarFiles is a list of terraform var files to use when running terraform plan
	VarFiles []string

	// PlanFilePath is the path to save the plan file
	PlanFilePath string

	// Vars is a map of terraform vars to use when running terraform plan
	Vars map[string]interface{}
}

func (o *PlanOptions) validate() error {
	return nil
}

func Plan(td *terradagger.Client, options *Options, planOptions *PlanOptions) error {
	if options == nil {
		options = &Options{}
	}

	if planOptions == nil {
		planOptions = &PlanOptions{}
	}

	if err := options.validate(); err != nil {
		return &errors.ErrTerraformPlanFailedToStart{
			ErrWrapped: err,
			Details:    "the options passed to the terraform command are invalid",
		}
	}

	if err := planOptions.validate(); err != nil {
		return &errors.ErrTerraformPlanFailedToStart{
			ErrWrapped: err,
			Details:    "the plan options passed to the terraform command are invalid",
		}
	}

	td.Logger.Info("All the options are valid, and the terraform plan command can be started.")

	tfInitCMD := commands.GetTerraformCommand("init", nil)
	tfPlanCMD := commands.GetTerraformCommand("plan", nil)
	tfInitCMD.OmitBinaryNameInCommand = true
	tfPlanCMD.OmitBinaryNameInCommand = true

	// Validate specific options.

	// Convert to a terraDagger format, in this case, there are more than
	// one command to run.
	cmds := []commands.Command{
		tfInitCMD,
		tfPlanCMD,
	}

	tfCMDDagger := commands.ConvertCommandsToDaggerFormat(cmds)
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
