package types

type ActionParams struct {
	WorkDir        *PipelineDir
	MountDir       *PipelineDir
	BaseDir        *PipelineDir
	EnvVars        map[string]string
	CMDs           []*ActionCommand
	ContainerImage string
}

type ActionConfig struct {
	IsParallel            bool
	InheritEnvVarsFromJob bool
	ExecutionRuntime      *ActionRuntime
}

type Action struct {
	ID           string
	Name         string
	Params       *ActionParams
	Config       *ActionConfig
	DependsOnIDs []string
}

type JobParams struct {
	Actions             []*ActionClient
	WorkDir             *PipelineDir
	MountDir            *PipelineDir
	BaseDir             *PipelineDir
	ContainerImage      string
	EnvVars             map[string]string
	OutputArtifactsPath string
}

type JobConfig struct {
	RunActionsInParallel bool
	FailFastOnTaskError  bool
	ContinueOnTaskError  bool
}

type Job struct {
	ID           string // Auto generated through UUID
	Name         string
	Params       *JobParams
	Config       *JobConfig
	DependsOnIDs []string
}

type PipelineParams struct {
	Jobs []*JobClient
}

type Pipeline struct {
	// Auto-evaluated or generated at runtime
	HostBaseDir string
	HomeDir     string
	Name        string
	ID          string // Auto generated through UUID

	// Pipeline parameters
	Params *PipelineParams
}
