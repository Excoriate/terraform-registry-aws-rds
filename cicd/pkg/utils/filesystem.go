package utils

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func DirExistAndHasContent(dirPath string) error {
	if dirPath == "" {
		return fmt.Errorf("directory path cannot be empty")
	}

	currentDir, _ := os.Getwd()

	_, err := os.Stat(dirPath)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("directory %s does not exist in current directory %s", dirPath, currentDir)
		}

		return fmt.Errorf("unexpected error when checking the directory %s: %v", dirPath, err)
	}

	return nil
}

func CreateDir(dirPath string) error {
	if dirPath == "" {
		return fmt.Errorf("directory path cannot be empty")
	}

	err := os.MkdirAll(dirPath, os.ModePerm)
	if err != nil {
		return fmt.Errorf("error creating directory %s: %v", dirPath, err)
	}

	return nil
}

func DirExist(path string) error {
	info, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("directory %s does not exist", path)
		}
		return fmt.Errorf("error checking the path %s: %v", path, err)
	}
	if !info.IsDir() {
		return fmt.Errorf("%s is not a directory", path)
	}
	return nil
}

func FindGitRepoDir(levels int) (string, error) {
	// Get the current working directory
	pathname, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("error getting current directory: %w", err)
	}

	// Convert to absolute path
	absPath, err := filepath.Abs(pathname)
	if err != nil {
		return "", fmt.Errorf("error converting path %s to absolute path: %w", pathname, err)
	}

	for i := 0; i < levels; i++ {
		gitPath := filepath.Join(absPath, ".git")
		if stat, err := os.Stat(gitPath); err == nil && stat.IsDir() {
			return absPath, nil
		}
		parentPath := filepath.Dir(absPath)

		// To avoid going beyond the root ("/" or "C:\"), check if we're already at the root
		if parentPath == absPath {
			return "", fmt.Errorf("reached root directory, no Git repository found")
		}

		absPath = parentPath
	}

	return "", fmt.Errorf("no Git repository found in %s or any of its parent directories", pathname)
}

func IsRelativePath(path string) error {
	if path == "" {
		return fmt.Errorf("failed to check if path is relative: path cannot be empty")
	}

	if filepath.IsAbs(path) {
		return fmt.Errorf("failed to check if path is relative: path %s is absolute", path)
	}

	return nil
}

func IsAbsolutePath(path string) error {
	if path == "" {
		return fmt.Errorf("failed to check if path is absolute: path cannot be empty")
	}

	if !filepath.IsAbs(path) {
		return fmt.Errorf("failed to check if path is absolute: path %s is relative", path)
	}

	return nil
}

func IsValidDir(path string) error {
	// Ensure we have an absolute path to avoid confusion with relative paths.
	absPath, err := filepath.Abs(path)
	if err != nil {
		return fmt.Errorf("failed to resolve absolute path: %w", err)
	}

	// Use os.Stat to check if the path exists and get file info.
	info, err := os.Stat(absPath)
	if err != nil {
		if os.IsNotExist(err) {
			// The path does not exist.
			return nil
		}
		// There was some problem accessing the path.
		return fmt.Errorf("failed to stat the path: %w", err)
	}

	// Check if the path is a directory.
	if !info.IsDir() {
		// The path is not a directory.
		return fmt.Errorf("path is not a directory: %s", absPath)
	}

	// The path is a valid directory.
	return nil
}

func IfEmptyDefaultToCurrentDir(path string) string {
	if path == "" || path == "." {
		currentDir, _ := os.Getwd()
		return currentDir
	}

	return path
}

func GetHomeDir() string {
	homeDir, _ := os.UserHomeDir()
	return homeDir
}

func GetCurrentDir() string {
	currentDir, _ := os.Getwd()
	return currentDir
}

type IsSubDirOfOptions struct {
	ParentDir string
	ChildDir  string
}

func IsSubDirOrSiblingDir(options *IsSubDirOfOptions) error {
	// Clean paths to eliminate any unnecessary parts.
	cleanParentDir := filepath.Clean(options.ParentDir)
	cleanChildDir := filepath.Clean(options.ChildDir)

	// Construct the full path of the child by joining it with the parent.
	fullChildDir := filepath.Join(cleanParentDir, cleanChildDir)

	// validate the constructed child path exists and is a directory.
	fileInfo, err := os.Stat(fullChildDir)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("the directory does not exist: %s", fullChildDir)
		}
		// There was some problem accessing the path.
		return fmt.Errorf("error accessing the directory: %w", err)
	}

	if !fileInfo.IsDir() {
		return fmt.Errorf("the path is not a directory: %s", fullChildDir)
	}

	return nil
}

type IsValidRelativeToBaseOptions struct {
	BaseDir      string
	RelativePath string
}

func IsValidRelativeToBase(o *IsValidRelativeToBaseOptions) error {
	// Check for an absolute path and reject it if found.
	relativePath := o.RelativePath
	baseDir := o.BaseDir
	if filepath.IsAbs(relativePath) {
		return fmt.Errorf("the path %q is absolute, expected a relative path", relativePath)
	}

	// Check for an empty relative path.
	if relativePath == "" {
		return fmt.Errorf("relative path cannot be empty")
	}

	// Construct the full path by combining the base directory with the relative path.
	fullPath := filepath.Join(baseDir, relativePath)

	// Clean the resulting path to resolve any ".." or "." elements.
	resolvedPath := filepath.Clean(fullPath)

	// validate the resolved path is within the base directory hierarchy.
	if !strings.HasPrefix(resolvedPath, baseDir) {
		return fmt.Errorf("the path %q is not within the base directory %q", resolvedPath, baseDir)
	}

	// Check whether the resolved directory exists and is indeed a directory.
	info, err := os.Stat(resolvedPath)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("the directory %q does not exist", resolvedPath)
		}
		return fmt.Errorf("error accessing the directory: %w", err)
	}
	if !info.IsDir() {
		return fmt.Errorf("the path %q is not a directory", resolvedPath)
	}

	return nil // The path is valid and exists as a directory.
}

func IsSubDirOf(options *IsSubDirOfOptions) error {
	// Ensure options are not nil
	if options == nil {
		return fmt.Errorf("options cannot be nil")
	}

	// Check for empty ParentDir and ChildDir
	if options.ParentDir == "" {
		return fmt.Errorf("parent directory cannot be empty")
	}
	if options.ChildDir == "" {
		return fmt.Errorf("child directory cannot be empty")
	}

	// Check for absolute path of ParentDir
	if !filepath.IsAbs(options.ParentDir) {
		return fmt.Errorf("parent directory must be an absolute path")
	}

	// Check that ChildDir is not absolute
	if filepath.IsAbs(options.ChildDir) {
		return fmt.Errorf("child directory must be a relative path")
	}

	// Clean paths to eliminate any unnecessary parts and resolve symlinks.
	cleanParentDir, err := filepath.EvalSymlinks(filepath.Clean(options.ParentDir))
	if err != nil {
		return fmt.Errorf("error resolving symlinks for parent directory: %w", err)
	}
	cleanChildDir := filepath.Clean(options.ChildDir)

	// Construct the full path of the child by joining it with the parent.
	fullChildDir := filepath.Join(cleanParentDir, cleanChildDir)

	// validate the constructed child path and ensure it's a directory.
	fileInfo, err := os.Stat(fullChildDir)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("child directory does not exist: %s", fullChildDir)
		}
		return fmt.Errorf("error accessing child directory: %w", err)
	}
	if !fileInfo.IsDir() {
		return fmt.Errorf("child path is not a directory: %s", fullChildDir)
	}

	// Ensure that fullChildDir is a subdirectory of cleanParentDir.
	relPath, err := filepath.Rel(cleanParentDir, fullChildDir)
	if err != nil {
		return fmt.Errorf("error determining if child directory is subdirectory of parent directory: %w", err)
	}

	// If the relative path starts with `..` or is equal to `.`, child directory is not a subdirectory.
	if strings.HasPrefix(relPath, "..") || relPath == "." {
		return fmt.Errorf("child directory is not a subdirectory of parent directory: %s", fullChildDir)
	}

	return nil
}

func IsSubDirOfOrRelativelyEqualsTo(options *IsSubDirOfOptions) error {
	if options == nil {
		return fmt.Errorf("failed to check if child directory is a subdirectory of parent directory" +
			" (or equals): options cannot be nil")
	}
	// Check for empty ChildDir.
	if options.ChildDir == "" {
		return fmt.Errorf("failed to check if child directory is a subdirectory of parent directory" +
			" (or equals): child directory cannot be empty")
	}

	// Check for absolute path of ChildDir.
	if filepath.IsAbs(options.ChildDir) {
		return fmt.Errorf("failed to check if child directory is a subdirectory of parent directory" +
			" (or equals): child directory cannot be an absolute path")
	}

	// Check for relative ParentDir.
	if !filepath.IsAbs(options.ParentDir) {
		return fmt.Errorf("failed to check if child directory is a subdirectory of parent directory" +
			" (or equals): parent directory must be an absolute path")
	}

	switch options.ChildDir {
	case ".":
		// If ChildDir is ".", it is considered the same as ParentDir.
		return nil
	default:
		// Delegate the check to the existing IsSubDirOf function.
		return IsSubDirOf(options)
	}
}

func AbsoluteToRelative(baseDir, absPath string) (string, error) {
	// validate that baseDir is a valid directory.
	if baseInfo, err := os.Stat(baseDir); err != nil {
		return "", fmt.Errorf("invalid base directory: %w", err)
	} else if !baseInfo.IsDir() {
		return "", fmt.Errorf("base path is not a directory: %s", baseDir)
	}

	// validate that absPath is a valid path and is absolute.
	if absInfo, err := os.Stat(absPath); err != nil {
		return "", fmt.Errorf("invalid absolute path: %w", err)
	} else if !absInfo.Mode().IsDir() && !absInfo.Mode().IsRegular() {
		return "", fmt.Errorf("path is not a directory or a regular file: %s", absPath)
	} else if !filepath.IsAbs(absPath) {
		return "", fmt.Errorf("path is not absolute: %s", absPath)
	}

	// Convert absolute path to relative.
	relPath, err := filepath.Rel(baseDir, absPath)
	if err != nil {
		return "", fmt.Errorf("failed to convert to relative path: %w", err)
	}

	return relPath, nil
}

// RelativeToAbsolute converts a relative path to an absolute path given a base directory.
// It also ensures that the base directory is valid and the formed absolute path is valid.
func RelativeToAbsolute(baseDir, relPath string) (string, error) {
	// validate that baseDir is a valid directory.
	if baseInfo, err := os.Stat(baseDir); err != nil {
		return "", fmt.Errorf("invalid base directory: %w", err)
	} else if !baseInfo.IsDir() {
		return "", fmt.Errorf("base path is not a directory: %s", baseDir)
	}

	// Construct the absolute path.
	absPath := filepath.Join(baseDir, relPath)

	// validate the absolute path.
	if absInfo, err := os.Stat(absPath); err != nil {
		return "", fmt.Errorf("invalid absolute path: %w", err)
	} else if !absInfo.Mode().IsDir() && !absInfo.Mode().IsRegular() {
		return "", fmt.Errorf("formed path is not a directory or a regular file: %s", absPath)
	}

	return absPath, nil
}

func FileExist(path string) error {
	info, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("file %s does not exist", path)
		}
		return fmt.Errorf("error checking the path %s: %v", path, err)
	}
	if info.IsDir() {
		return fmt.Errorf("%s is a directory", path)
	}
	return nil
}
