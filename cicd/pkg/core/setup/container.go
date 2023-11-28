package setup

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/params"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"

	"dagger.io/dagger"
)

// DaggerDir sets up the dagger directory.
func DaggerDir(dirPath string, c *dagger.Client) (*dagger.Directory, error) {
	if dirPath == "" {
		return nil, fmt.Errorf("the directory passed is not valid, it's passed as empty")
	}

	if c == nil {
		return nil, fmt.Errorf("the dagger client passed is not valid, it's passed as nil")
	}

	return c.Host().Directory(dirPath), nil
}

func AttachRuntimeDirsInContainer(runtime *types.ActionRuntime,
	container *dagger.Container) *dagger.
	Container {
	if runtime == nil {
		return container
	}

	if container == nil {
		return container
	}

	if runtime.MountDir == nil {
		return container
	}

	mntPrefix := params.GetDaggerMntDirPrefix()
	container = container.WithDirectory(mntPrefix, runtime.MountDir.DaggerDir)

	if runtime.Workdir == nil {
		return container
	}

	// workDirRelative := filepath.Join(mntPrefix, runtime.Workdir.RelativePath)
	// workDirRelative := filepath.Join(mntPrefix, "/modules/default")
	// container = container.WithWorkdir(workDirRelative)
	container = container.WithWorkdir(runtime.Workdir.AbsolutePath)

	for _, cmd := range runtime.CMDs {
		container = container.WithExec(cmd.CMDToRun) // If there's no 'sync' call,
		// they aren't evaluated.
	}

	return container
}
