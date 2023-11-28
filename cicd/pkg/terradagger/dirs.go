package pipeline

import (
	"fmt"
	"path/filepath"

	"dagger.io/dagger"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"
)

type Dir struct {
	MountDir               *dagger.Directory
	WorkDirPath            string
	WorkDirPathInContainer string
}

const mountPathPrefix = "/mnt"

func resolveDirs(client *dagger.Client, mountDir, workDir string) (*Dir, error) {
	mountDirDagger := client.Host().Directory(mountDir)
	workDirPathInContainer := fmt.Sprintf("%s/%s", mountPathPrefix, filepath.Clean(workDir))

	return &Dir{
		MountDir:               mountDirDagger,
		WorkDirPath:            workDir,
		WorkDirPathInContainer: workDirPathInContainer,
	}, nil
}

func resolveMountDirPath(mountDirPath string) (string, error) {
	currentDir := utils.GetCurrentDir()
	if mountDirPath == "" {
		return filepath.Join(currentDir, "/", "."), nil
	}

	mountDirPath = filepath.Join(currentDir, "/", mountDirPath)

	if err := utils.IsValidDir(mountDirPath); err != nil {
		return "", err
	}

	return mountDirPath, nil
}
