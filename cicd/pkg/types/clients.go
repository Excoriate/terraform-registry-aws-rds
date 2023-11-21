package types

import (
	"context"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
)

type ActionClient struct {
	API *Action

	// Implementation details, and internals.
	Logger o11y.LoggerInterface
	Ctx    context.Context
}

type JobClient struct {
	API *Job

	// Implementation details, and internals.
	Logger o11y.LoggerInterface
	Ctx    context.Context
}
