package pipeline

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/env"
)

// ActionsInheritEnvVarsFromJob iterates over each job, and for each job, it'll check if there are env vars, if so
// it'll add them to the action for that specific job.
func ActionsInheritEnvVarsFromJob(p *Client) error {
	if p == nil {
		return fmt.Errorf("failed to inherit env vars from job: pipeline is nil")
	}

	// Iterate over each job, and for each job, it'll check if there are env vars, if so
	// it'll add them to the action for that specific job.
	for _, job := range p.API.Params.Jobs {
		if len(job.API.Params.EnvVars) == 0 {
			p.Logger.Info(fmt.Sprintf("Job ID %s has no env vars to inherit", job.API.ID))
			continue
		}

		for _, action := range job.API.Params.Actions {
			if len(action.API.Params.EnvVars) == 0 {
				action.API.Params.EnvVars = job.API.Params.EnvVars
				p.Logger.Info(fmt.Sprintf("Action ID %s has inherited env vars from job ID %s", action.API.ID, job.API.ID))
				continue
			}

			action.API.Params.EnvVars = env.MergeEnvVars(action.API.Params.EnvVars, job.API.Params.EnvVars)
			p.Logger.Info(fmt.Sprintf("Action ID %s has inherited env vars from job ID %s by mergin its vars", action.API.ID, job.API.ID))
		}
	}

	return nil
}
