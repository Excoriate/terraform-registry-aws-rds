package executor

import (
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/pipeline"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
)

type Executor interface {
	ExecuteAction(action *types.ActionClient) error
}

type Client struct {
	pipeline *pipeline.Client
}

func New(pipeline *pipeline.Client) Executor {
	return &Client{
		pipeline: pipeline,
	}
}

func (c *Client) ExecuteAction(action *types.ActionClient) error {
	container := action.API.Config.ExecutionRuntime.ContainerRuntime
	_, err := container.Sync(action.Ctx)

	if err != nil {
		return err
	}

	return nil
}
