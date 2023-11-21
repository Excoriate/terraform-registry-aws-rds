package pipeline

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
)

// ValidatePipelineHasJobs validates that the pipeline has jobs.
// This is a very simple validation, but it's a good start.
func ValidatePipelineHasJobs(pipeline *Client) error {
	if pipeline == nil {
		return fmt.Errorf("pipeline is nil")
	}

	if len(pipeline.API.Params.Jobs) == 0 {
		return fmt.Errorf("pipeline has no jobs")
	}

	for _, job := range pipeline.API.Params.Jobs {
		pipeline.Logger.Info(fmt.Sprintf("Pipeline ID %s has job %s", pipeline.API.ID, job.API.Name))
	}

	return nil
}

// ValidateJobHasActions validates that the job has actions.
func ValidateJobHasActions(job *types.JobClient) error {
	if job == nil {
		return fmt.Errorf("job is nil")
	}

	if len(job.API.Params.Actions) == 0 {
		return fmt.Errorf("job has no Actions to run")
	}

	for _, action := range job.API.Params.Actions {
		job.Logger.Info(fmt.Sprintf("Job ID %s has action %s", job.API.ID, action.API.Name))
	}

	return nil
}

// ValidateActionHasCommandsToRun validates that the action has commands to run.
func ValidateActionHasCommandsToRun(action *types.ActionClient) error {
	if action == nil {
		return fmt.Errorf("action is nil")
	}

	if len(action.API.Params.CMDs) == 0 {
		return fmt.Errorf("action has no commands to run")
	}

	for _, cmd := range action.API.Params.CMDs {
		action.Logger.Info(fmt.Sprintf("Action ID %s has command %s", action.API.ID, cmd))
	}

	return nil
}
