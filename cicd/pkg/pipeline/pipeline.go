package pipeline

import (
	"context"
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/params"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/engine"

	"dagger.io/dagger"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
)

type InitPipelineOptions struct {
	// Pipeline parameters
	Name string
	Jobs []*types.JobClient
	// Optionally, a dagger client can be passed in.
	DaggerClient *dagger.Client
}

type InitPipelineOptionsFunc func(*InitPipelineOptions) error

type Builder struct {
	logger o11y.LoggerInterface
	ctx    context.Context
}

type Client struct {
	API *types.Pipeline

	// Implementation details, and internals.
	Logger       o11y.LoggerInterface
	Ctx          context.Context
	DaggerClient *dagger.Client
}

func NewPipeline(ctx context.Context, logger o11y.LoggerInterface) *Builder {
	return &Builder{
		ctx:    ctx,
		logger: logger,
	}
}

func (b *Builder) Build(opts ...InitPipelineOptionsFunc) (*Client, error) {
	options := &InitPipelineOptions{}
	for _, opt := range opts {
		if err := opt(options); err != nil {
			return nil, err
		}
	}

	// Managing defaults
	if options.Name == "" {
		options.Name = params.GetDefaultRandomName()
	}

	// Pipeline parameters
	name := options.Name
	id := params.GenerateID()

	// Dagger client logic, if it's not passed, a new one will be created.
	var dc *dagger.Client

	if options.DaggerClient == nil {
		b.logger.Info("No dagger client passed in, creating a new one.")

		daggerBuilder := engine.NewDaggerClient(b.ctx, b.logger)
		c, err := daggerBuilder.Build(daggerBuilder.WithLogOutput())
		if err != nil {
			b.logger.Error("Error building dagger client", err)
			return nil, err
		}

		dc = c.Client
	} else {
		dc = options.DaggerClient
	}

	c := &Client{
		Logger:       b.logger,
		Ctx:          b.ctx,
		DaggerClient: dc,
		API: &types.Pipeline{
			ID:          id,
			Name:        name,
			HostBaseDir: utils.GetCurrentDir(),
			HomeDir:     utils.GetHomeDir(),
			Params: &types.PipelineParams{
				Jobs: options.Jobs,
			},
		},
	}

	return c, nil
}

func (b *Builder) WithJob(job ...*types.JobClient) InitPipelineOptionsFunc {
	return func(options *InitPipelineOptions) error {
		if job == nil {
			b.logger.Error("Job passed in is nil")
			return fmt.Errorf("failed to add job to pipeline, job passed in is nil")
		}

		options.Jobs = append(options.Jobs, job...)
		return nil
	}
}

func (b *Builder) WithDaggerClient(dc *dagger.Client) InitPipelineOptionsFunc {
	return func(options *InitPipelineOptions) error {
		if dc == nil {
			b.logger.Error("Dagger client passed in is nil")
			return fmt.Errorf("dagger client passed in is nil")
		}

		options.DaggerClient = dc

		return nil
	}
}

func (b *Builder) WithName(name string) InitPipelineOptionsFunc {
	return func(options *InitPipelineOptions) error {
		if options.Name == "" {
			b.logger.Warn("Name passed in is empty, a random name will be generated.")
			options.Name = params.GetDefaultRandomName()

			b.logger.Info("Name generated", options.Name)
			return nil
		}

		options.Name = name
		b.logger.Info("Name passed in", options.Name)

		return nil
	}
}
