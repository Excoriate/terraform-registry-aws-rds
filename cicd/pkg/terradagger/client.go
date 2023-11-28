package pipeline

import (
	"context"
	"fmt"
	"os"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/errors"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/daggerio"

	"dagger.io/dagger"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/env"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
)

type Client struct {
	// Implementation details, and internals.
	Logger      o11y.LoggerInterface
	ID          string
	Ctx         context.Context
	CurrentDir  string
	HomeDir     string
	HostEnvVars map[string]string
	// Client           *dagger.Client
	ContainerFactory daggerio.Container
	MountDir         string
	DaggerClient     *dagger.Client
}

type PipelineConfigOptions struct {
	Image    string
	EnvVars  map[string]string
	Workdir  string
	MountDir string
	CMDs     [][]string
}

type Pipeline interface {
	// Configure the pipeline, which includes:
	// 1. The dagger client is connected, and properly configured.
	// 2. The image is pulled, and the container is configured.
	// 3. The container is mounted, and the workdir is set.
	Configure(options *PipelineConfigOptions) (*dagger.Container, error)

	// Run the pipeline.
	Run(container *dagger.Container) error
}

// newDaggerClient creates a new dagger client.
// If no options are passed, the default options are used.
func newDaggerClient(ctx context.Context, options ...dagger.ClientOpt) (*dagger.
	Client, error) {
	if ctx == nil {
		ctx = context.Background()
	}

	var daggerOptions []dagger.ClientOpt

	if len(options) == 0 {
		return dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	}

	// If options are passed, append them to the daggerOptions.
	daggerOptions = append(daggerOptions, options...)

	return dagger.Connect(ctx, daggerOptions...)
}

type NewPipelineOptions struct {
	RootDir                     string
	WithStderrLogInDaggerClient bool
}

func New(ctx context.Context, options *NewPipelineOptions) (*Client, error) {
	l := o11y.NewLogger(o11y.LoggerOptions{
		EnableJSONHandler: true,
		EnableStdError:    true,
	})

	hostEnvVars := env.GetAllFromHost()
	currentDir := utils.GetCurrentDir()
	id := utils.GetUUID()

	l.Info(fmt.Sprintf("Starting pipeline with id %s", id))

	client := &Client{
		Logger:      l,
		ID:          id,
		Ctx:         ctx,
		CurrentDir:  currentDir,
		HomeDir:     utils.GetHomeDir(),
		HostEnvVars: hostEnvVars,
	}

	if options == nil {
		l.Info("No options passed to the pipeline. Using default options. Also, " +
			"the mountDir will be set to '.' (current directory).")

		daggerClient, err := newDaggerClient(ctx, dagger.WithLogOutput(os.Stdout))
		if err != nil {
			return nil, errors.NewTerraDaggerError(errors.ErrDaggerClientCannotStart, "", err)
		}

		client.DaggerClient = daggerClient
		client.MountDir = "."

		l.Info("TerraDagger client started successfully.")
		return client, nil
	}

	var daggerClientOptions []dagger.ClientOpt

	if options.WithStderrLogInDaggerClient {
		daggerClientOptions = append(daggerClientOptions, dagger.WithLogOutput(os.Stderr))
	} else {
		daggerClientOptions = append(daggerClientOptions, dagger.WithLogOutput(os.Stdout))
	}

	daggerClient, err := newDaggerClient(ctx, daggerClientOptions...)
	if err != nil {
		return nil, err
	}

	client.DaggerClient = daggerClient

	mountDirPath, err := resolveMountDirPath(options.RootDir)
	if err != nil {
		return nil, err
	}

	client.MountDir = mountDirPath

	if options.WithStderrLogInDaggerClient {
		daggerClient, err := newDaggerClient(ctx, dagger.WithLogOutput(os.Stderr))
		if err != nil {
			return nil, err
		}

		client.DaggerClient = daggerClient
	}

	return client, nil
}

func (p *Client) Configure(options *PipelineConfigOptions) (*dagger.Container, error) {
	dirs, err := resolveDirs(p.DaggerClient, options.MountDir, options.Workdir)
	if err != nil {
		return nil, err
	}

	container := p.DaggerClient.Container().From("hashicorp/terraform:latest").
		WithMountedDirectory(mountPathPrefix, dirs.MountDir).
		WithWorkdir(dirs.WorkDirPathInContainer)

	for _, cmds := range options.CMDs {
		container = container.WithExec(cmds)
	}

	return container, nil
}

func (p *Client) Run(container *dagger.Container) error {
	_, err := container.Stdout(p.Ctx)
	if err != nil {
		return err
	}

	return nil
}
