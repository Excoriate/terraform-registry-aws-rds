package engine

import (
	"context"
	"fmt"
	"os"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"dagger.io/dagger"
)

type InitDaggerClientOptions struct {
	EnableLogOutput bool
	WorkDir         string
}

type InitDaggerClientOptionsFunc func(*InitDaggerClientOptions) error

type Builder struct {
	l   o11y.LoggerInterface
	ctx context.Context
}

type DaggerPipelineClient struct {
	Logger      o11y.LoggerInterface
	Ctx         context.Context
	Client      *dagger.Client
	HostRootDir string
}

func NewDaggerClient(ctx context.Context, l o11y.LoggerInterface) *Builder {
	return &Builder{
		l:   l,
		ctx: ctx,
	}
}

func (b *Builder) WithLogOutput() InitDaggerClientOptionsFunc {
	return func(options *InitDaggerClientOptions) error {
		options.EnableLogOutput = true
		return nil
	}
}

func (b *Builder) WithStartWithCurrentWorkDir() InitDaggerClientOptionsFunc {
	return func(options *InitDaggerClientOptions) error {
		if options.WorkDir != "" {
			return fmt.Errorf("workdir is already set to %s", options.WorkDir)
		}

		currentDir, _ := os.Getwd()
		options.WorkDir = currentDir

		return nil
	}
}

func (b *Builder) WithWorkDir(workDir string) InitDaggerClientOptionsFunc {
	return func(options *InitDaggerClientOptions) error {
		if err := utils.DirExistAndHasContent(workDir); err != nil {
			return fmt.Errorf("error checking the directory %s: %v", workDir, err)
		}

		options.WorkDir = workDir
		return nil
	}
}

func (b *Builder) Build(optionsFunc ...InitDaggerClientOptionsFunc) (*DaggerPipelineClient, error) {
	options := &InitDaggerClientOptions{}
	for _, f := range optionsFunc {
		if err := f(options); err != nil {
			return nil, err
		}
	}

	var c *dagger.Client
	var daggerOptions []dagger.ClientOpt

	if options.EnableLogOutput {
		daggerOptions = append(daggerOptions, dagger.WithLogOutput(os.Stdout))
	}

	if options.WorkDir != "" {
		daggerOptions = append(daggerOptions, dagger.WithWorkdir(options.WorkDir))
	}

	c, err := dagger.Connect(b.ctx, daggerOptions...)
	if err != nil {
		return nil, fmt.Errorf("error connecting to dagger: %v", err)
	}

	rootHostDir, _ := os.Getwd()

	return &DaggerPipelineClient{
		Logger:      b.l,
		Ctx:         b.ctx,
		Client:      c,
		HostRootDir: rootHostDir,
	}, nil
}
