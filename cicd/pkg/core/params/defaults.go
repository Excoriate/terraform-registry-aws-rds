package params

import (
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"
)

// GetDefaultWorkDir returns the default working directory for the pipeline.
// Job, or the Action if requested. It always resolves to the current working
// directory.
func GetDefaultWorkDir() string {
	return utils.GetCurrentDir()
}

// GetBaseDir returns the default working directory for the pipeline.
func GetBaseDir() string {
	return utils.GetCurrentDir()
}

func GetDefaultMountDir() string {
	return utils.GetCurrentDir()
}

// GetDefaultEmptyEnvVars returns an empty map of environment variables.
func GetDefaultEmptyEnvVars() map[string]string {
	return map[string]string{}
}

// GetDefaultRandomName returns a random name.
func GetDefaultRandomName() string {
	return utils.GenerateRandomName(2)
}

// GenerateID GetDefaultRandomID returns a random ID.
func GenerateID() string {
	return utils.GetUUID()
}

// GetDefaultDependenciesOnIDs returns an empty list of dependencies.
func GetDefaultDependenciesOnIDs() []string {
	return []string{}
}

// GetDefaultOutputArtifactPath returns the default output artifact path.
func GetDefaultOutputArtifactPath() string {
	return "/output"
}

func IfBaseDirIsEmptyDefaultToCurrent(baseDir string) string {
	return utils.IfEmptyDefaultToCurrentDir(baseDir)
}

func IfMountDirIsEmptyDefaultToCurrent(mountDir string) string {
	return utils.IfEmptyDefaultToCurrentDir(mountDir)
}

func GetDaggerMntDirPrefix() string {
	return "/mnt"
}

func GetDefaultCommandOptions() []*types.ActionCommand {
	return []*types.ActionCommand{
		{
			CMDToRun:       []string{},
			ReturnExitCode: true,
			ReturnStdout:   false,
			ReturnStderr:   false,
		},
	}
}
