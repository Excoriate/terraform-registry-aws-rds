package engine_test

import (
	"context"
	"testing"

	clients "github.com/Excoriate/terraform-registry-aws-rds/pkg/core/engine"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"

	"github.com/stretchr/testify/assert"
)

func TestDaggerClient(t *testing.T) {
	// TODO: Yes... should be a mock ;)
	logger := o11y.NewLogger(o11y.LoggerOptions{
		EnableJSONHandler: false,
		EnableStdError:    false,
	})

	ctx := context.TODO()

	builder := clients.NewDaggerClient(ctx, logger)
	t.Parallel()

	t.Run("Test WithLogOutput", func(t *testing.T) {
		c, err := builder.Build(builder.WithLogOutput())
		assert.NoErrorf(t, err, "expected no error when setting log output")
		assert.NotNilf(t, c.Logger, "expected logger when setting log output")
		assert.NotNilf(t, c.Ctx, "expected context when setting log output")
		assert.NotNilf(t, c.Client, "expected dagger client when setting log output")
	})

	t.Run("Test WithStartWithCurrentWorkDir", func(t *testing.T) {
		c, err := builder.Build(builder.WithStartWithCurrentWorkDir())
		assert.NoErrorf(t, err, "expected no error when setting work dir")
		assert.NotNilf(t, c.Logger, "expected logger when setting work dir")
		assert.NotNilf(t, c.Ctx, "expected context when setting work dir")
		assert.NotNilf(t, c.Client, "expected dagger client when setting work dir")
	})

	t.Run("Should fail when setting work dir twice", func(t *testing.T) {
		c, err := builder.Build(builder.WithStartWithCurrentWorkDir(),
			builder.WithWorkDir("some_dir"))
		assert.Nilf(t, c, "expected nil dagger client when setting work dir twice")
		assert.Errorf(t, err, "expected error when setting work dir twice")
		assert.NotEmptyf(t, err, "expected error when setting work dir twice")
	})

	t.Run("Should fail if the workDir set does not exist", func(t *testing.T) {
		c, err := builder.Build(builder.WithWorkDir("some_dir"))
		assert.Nilf(t, c, "expected nil dagger client when setting work dir that does not exist")
		assert.Errorf(t, err, "expected error when setting work dir that does not exist")
		assert.NotEmptyf(t, err, "expected error when setting work dir that does not exist")
	})
}
