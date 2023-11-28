package terradagger

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/errors"

	"dagger.io/dagger"
)

const defaultImageVersion = "latest"

type NewContainerOptions struct {
	Image   string
	Version string
}

type ContainerFactory interface {
	create(options *NewContainerOptions) (*dagger.Container, error)
	// withEnvVars(envVars map[string]string) *dagger.Container
	withDirs(container *dagger.Container, mountDir *dagger.Directory,
		workDirPath string) *dagger.Container
	withCommands(container *dagger.Container, commands [][]string) *dagger.Container
	withEnvVars(container *dagger.Container, envVars map[string]string) *dagger.Container
}

type Container struct {
	client *Client
}

func NewContainer(td *Client) *Container {
	return &Container{
		client: td,
	}
}

func buildImageName(image, version string) string {
	if version == "" {
		version = defaultImageVersion
	}

	return fmt.Sprintf("%s:%s", image, version)
}

func (c *Container) create(options *NewContainerOptions) (*dagger.Container, error) {
	if options == nil {
		return nil, &errors.ErrTerraDaggerInvalidArgumentError{
			Details: "options cannot be nil",
		}
	}

	if options.Image == "" {
		return nil, &errors.ErrTerraDaggerInvalidArgumentError{
			Details: "the image while creating a new container cannot be nil or empty",
		}
	}

	imageWithVersion := buildImageName(options.Image, options.Version)
	c.client.Logger.Info(fmt.Sprintf("Creating a new container with image: %s", imageWithVersion))

	return c.client.DaggerClient.Container().From(imageWithVersion), nil
}

func (c *Container) withDirs(container *dagger.Container, mountDir *dagger.Directory,
	workDirPath string) *dagger.Container {
	// container = container.WithMountedDirectory(mountPathPrefix, mountDir)
	container = container.WithDirectory(mountPathPrefix, mountDir)
	container = container.WithWorkdir(workDirPath)

	return container
}

func (c *Container) withCommands(container *dagger.Container, commands [][]string) *dagger.Container {
	for _, cmds := range commands {
		container = container.WithExec(cmds)
	}

	return container
}

func (c *Container) withEnvVars(container *dagger.Container, envVars map[string]string) *dagger.Container {
	for key, value := range envVars {
		container = container.WithEnvVariable(key, value)
	}

	return container
}
