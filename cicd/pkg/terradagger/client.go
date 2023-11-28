package terradagger

import (
	"context"
	"fmt"
	"io"
	"os"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/errors"

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
	MountDir     string
	DaggerClient *dagger.Client
}

type ClientConfigOptions struct {
	Image    string
	Version  string
	EnvVars  map[string]string
	Workdir  string
	MountDir string
	CMDs     [][]string
}

type Core interface {
	// Configure the terradagger, which includes:
	// 1. The dagger client is connected, and properly configured.
	// 2. The image is pulled, and the container is configured.
	// 3. The container is mounted, and the workdir is set.
	Configure(options *ClientConfigOptions) (*dagger.Container, error)

	// Run the terradagger.
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

// ClientOptions are the options for the terradagger client.
// RootDir is the root directory of the terradagger client.
// WithStderrLogInDaggerClient is a flag to enable stderr as log output for the dagger client.
type ClientOptions struct {
	RootDir                     string
	WithStderrLogInDaggerClient bool
}

// New creates a new terradagger client.
// If no options are passed, the default options are used.
func New(ctx context.Context, options *ClientOptions) (*Client, error) {
	l := o11y.NewLogger(o11y.LoggerOptions{
		EnableJSONHandler: true,
		EnableStdError:    true,
	})

	hostEnvVars := env.GetAllFromHost()
	currentDir := utils.GetCurrentDir()
	id := utils.GetUUID()

	l.Info(fmt.Sprintf("Starting terradagger with id %s", id))

	client := &Client{
		Logger:      l,
		ID:          id,
		Ctx:         ctx,
		CurrentDir:  currentDir,
		HomeDir:     utils.GetHomeDir(),
		HostEnvVars: hostEnvVars,
	}

	var logOutput io.Writer = os.Stdout // Default log output is stdout

	if options != nil {
		// Adjust log output if option is provided
		if options.WithStderrLogInDaggerClient {
			l.Debug("Using stderr as log output for dagger client.")
			logOutput = os.Stderr
		}
		mountDirPath, mountErr := resolveMountDirPath(options.RootDir)
		if mountErr != nil {
			return nil, &errors.ErrTerraDaggerInitializationError{
				ErrWrapped: mountErr,
				Details:    fmt.Sprintf("the mountDir could not be resolved with root directory: %s", options.RootDir),
			}
		}
		client.MountDir = mountDirPath
		l.Info(fmt.Sprintf("Mount directory resolved to: %s", client.MountDir))
	}

	daggerClient, err := newDaggerClient(ctx, dagger.WithLogOutput(logOutput))
	if err != nil {
		return nil, &errors.ErrTerraDaggerInitializationError{
			ErrWrapped: err,
			Details:    "the dagger client could not be started",
		}
	}

	client.DaggerClient = daggerClient

	if options == nil {
		client.MountDir = "." // Default mount directory set to current directory
	}

	l.Info("TerraDagger client started successfully.")
	return client, nil
}

func (p *Client) Configure(options *ClientConfigOptions) (*dagger.Container, error) {
	dirs := getDirs(p.DaggerClient, options.MountDir, options.Workdir)

	tdContainer := NewContainer(p)
	container, err := tdContainer.create(&NewContainerOptions{
		Image:   options.Image,
		Version: options.Version,
	})

	if err != nil {
		return nil, err
	}

	container = tdContainer.withDirs(container, dirs.MountDir, dirs.WorkDirPathInContainer)
	container = tdContainer.withCommands(container, options.CMDs)

	if len(options.EnvVars) > 0 {
		container = tdContainer.withEnvVars(container, options.EnvVars)
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