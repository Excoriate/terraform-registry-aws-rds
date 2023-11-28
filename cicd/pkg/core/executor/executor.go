package executor

import (
	"fmt"
	"path/filepath"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
)

type Executor interface {
	ExecuteAction(action *types.ActionClient) error
}

func ExecuteAction(action *types.ActionClient) error {
	// Getting the container runtime.
	// container := action.API.Config.ExecutionRuntime.ContainerRuntime
	// baseDir := action.API.Config.ExecutionRuntime.BaseDir
	mountDir := action.API.Config.ExecutionRuntime.MountDir
	workDir := action.API.Config.ExecutionRuntime.Workdir

	// Iterate over the commands for this action
	// src := action.API.Config.ExecutionRuntime.Client.Host().Directory(".")
	// workDir := action.API.Config.ExecutionRuntime.Workdir

	// WithMountedDirectory("/mnt", workDir.DaggerDir)
	workDirRuntime := filepath.Join("/mnt", mountDir.RelativePath, workDir.RelativePath)
	action.API.Config.ExecutionRuntime.Container = action.API.Config.ExecutionRuntime.Container.
		WithDirectory("/mnt", workDir.DaggerDir).
		WithWorkdir(workDirRuntime)

		// action.API.Config.ExecutionRuntime.Container = action.API.Config.ExecutionRuntime.Container.
	// 	WithWorkdir(workDirRuntime)
	// action.API.Config.ExecutionRuntime.Container = action.API.Config.ExecutionRuntime.Container.WithDirectory("/mnt", mountDir.DaggerDir)
	// action.API.Config.ExecutionRuntime.Container = action.API.Config.ExecutionRuntime.Container.WithWorkdir("/mnt/modules/default")

	for _, cmd := range action.API.Config.ExecutionRuntime.CMDs {
		out, err := action.API.Config.ExecutionRuntime.Container.WithExec(cmd.CMDToRun).Stdout(action.Ctx)
		fmt.Println(out)

		if err != nil {
			return err
		}

	}

	return nil
}
