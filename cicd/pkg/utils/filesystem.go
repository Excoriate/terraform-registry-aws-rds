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

func IsSubDirOf(options *IsSubDirOfOptions) error {
	if options == nil {
		return fmt.Errorf("failed to check if child directory is a subdirectory of parent directory: options cannot be nil")
	}

	// Clean paths to eliminate any unnecessary parts.
	cleanParentDir := filepath.Clean(options.ParentDir)
	cleanChildDir := filepath.Clean(options.ChildDir)

	// Resolve absolute paths.
	absParentDir, err := filepath.Abs(cleanParentDir)
	if err != nil {
		return fmt.Errorf("error resolving absolute path for parent directory: %w", err)
	}

	absChildDir, err := filepath.Abs(cleanChildDir)
	if err != nil {
		return fmt.Errorf("error resolving absolute path for child directory: %w", err)
	}

	// The child is not a subdirectory if the paths are identical.
	if absParentDir == absChildDir {
		return fmt.Errorf("child directory is not a subdirectory of parent directory: child directory and parent directory are identical")
	}

	// We add the os specific PathSeparator to the end of the parent directory to ensure that
	// we don't have substring matches such as `/a/b` and `/a/bc`.
	if !strings.HasSuffix(absParentDir, string(os.PathSeparator)) {
		absParentDir += string(os.PathSeparator)
	}

	// Check if absChildDir starts with absParentDir.
	if !strings.HasPrefix(absChildDir, absParentDir) {
		return fmt.Errorf("child directory is not a subdirectory of parent directory: child directory does not start with parent directory")
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
