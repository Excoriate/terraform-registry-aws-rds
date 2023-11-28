package types

import "dagger.io/dagger"

type PipelineDir struct {
	RelativePath string
	AbsolutePath string
	CurrentDir   string
	DaggerDir    *dagger.Directory
	HomeDir      string
}

type ActionRuntime struct {
	Container        *dagger.Container
	ContainerRuntime *dagger.Container
	Client           *dagger.Client
	BaseDir          *PipelineDir
	Workdir          *PipelineDir
	MountDir         *PipelineDir
	CMDs             []*ActionCommand
}

type ActionCommand struct {
	CMDToRun       []string
	ReturnStdout   bool
	ReturnStderr   bool
	ReturnExitCode bool // the default option.
}
