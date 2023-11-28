package terraform

import (
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

	return nil
}
