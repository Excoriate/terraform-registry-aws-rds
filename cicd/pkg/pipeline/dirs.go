package pipeline

import (
	"fmt"
	"path/filepath"

	"dagger.io/dagger"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/core/params"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/types"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"
)

type GetMountDirOptions struct {
	BaseDir  string
	MountDir string
}

// GetMountDir validates that the workdir is valid.
// The mountDir is a directory from the host that'll be copied to the
// container when it's started by the dagger engine.
// It should be relative to the baseDir, and it should be a valid directory.
func GetMountDir(o *GetMountDirOptions) (*types.PipelineDir, error) {
	if o == nil {
		return nil, fmt.Errorf("failed to validate mountDir: options are nil")
	}

	// If the mountDir is empty, it'll default to the current working directory.
	o.BaseDir = params.IfBaseDirIsEmptyDefaultToCurrent(o.BaseDir)
	o.MountDir = params.IfMountDirIsEmptyDefaultToCurrent(o.MountDir)
	if o.MountDir == o.BaseDir {
		return &types.PipelineDir{
				CurrentDir:   utils.GetCurrentDir(),
				AbsolutePath: o.MountDir,
				RelativePath: ".", // It's the current directory.
				DaggerDir:    &dagger.Directory{},
			},
			nil
	}

	// if it's not empty or explicitly set to the current dir, it's subject to validations.
	if err := utils.IsRelativePath(o.MountDir); err != nil {
		return nil, fmt.Errorf("failed to validate mountDir, "+
			"the mountDir cannot be an absolute path: %w", err)
	}

	baseDir := params.IfBaseDirIsEmptyDefaultToCurrent(o.BaseDir)

	mountDirFullPath := filepath.Join(baseDir, o.MountDir)

	if err := utils.IsValidDir(mountDirFullPath); err != nil {
		return nil, fmt.Errorf("failed to validate mountDir, invalid mountDir: %w", err)
	}

	return &types.PipelineDir{
		CurrentDir:   utils.GetCurrentDir(),
		AbsolutePath: mountDirFullPath,
		RelativePath: o.MountDir,
		DaggerDir:    &dagger.Directory{},
	}, nil
}

type GetWorkDirOptions struct {
	MountDir string
	WorkDir  string
}

// GetWorkDir validates that the workdir is valid.
// The workDir is a directory from the container that'll be used as the
// working directory for the commands to run.
func GetWorkDir(o *GetWorkDirOptions) (*types.PipelineDir, error) {
	if o == nil {
		return nil, fmt.Errorf("failed to validate workDir: options are nil")
	}

	if o.MountDir == "" {
		o.MountDir = params.IfMountDirIsEmptyDefaultToCurrent(o.MountDir)
		// return nil, fmt.Errorf("failed to validate workDir: mountDir is empty")
	}

	if o.WorkDir == "" {
		// Should resolve to the mountDir then.
		o.WorkDir = "."
		// return nil, fmt.Errorf("failed to validate workDir: workDir is empty")
	}

	// The workDir can't be absolute, should be relative
	if err := utils.IsRelativePath(o.WorkDir); err != nil {
		return nil, fmt.Errorf("failed to validate workDir: workDir is not relative: %w", err)
	}

	// the WorkDir should be relative to the mountDir
	if err := utils.IsSubDirOfOrRelativelyEqualsTo(&utils.IsSubDirOfOptions{
		ParentDir: o.MountDir,
		ChildDir:  o.WorkDir,
	}); err != nil {
		return nil, fmt.Errorf("failed to validate workDir: workDir is not a subdirectory of mountDir")
	}

	// After compose the workDir, it should be validated as a valid directory.
	workDirFullPath := filepath.Join(o.MountDir, o.WorkDir)
	if err := utils.IsValidDir(workDirFullPath); err != nil {
		return nil, fmt.Errorf("failed to validate workDir: invalid workDir: %w", err)
	}

	return &types.PipelineDir{
		CurrentDir:   utils.GetCurrentDir(),
		AbsolutePath: workDirFullPath,
		RelativePath: o.WorkDir,
		DaggerDir:    &dagger.Directory{},
	}, nil
}

// GetBaseDir create a pipeline directory object from a valid path passed.
// The base directory represents the core where the pipeline will run, and understand
// its hierarchy of folders (baseDir -> mountDir -> workDir).
func GetBaseDir(baseDir string) (*types.PipelineDir, error) {
	// Resolve to current directory if baseDir is not set or is explicitly ".".
	if baseDir == "" || baseDir == "." {
		baseDir = utils.GetCurrentDir()
	} else {
		// Validate the provided baseDir.
		if err := utils.IsValidDir(baseDir); err != nil {
			return nil, fmt.Errorf("baseDir validation failed: %w", err)
		}
	}

	// Construct the pipeline directory object.
	return &types.PipelineDir{
		CurrentDir:   baseDir, // CurrentDir should be set to baseDir if it's already verified
		AbsolutePath: baseDir, // Assume baseDir is an absolute path after validation
		RelativePath: ".",     // RelativePath within the baseDir context is "."
		DaggerDir:    &dagger.Directory{},
	}, nil
}
