package tf

import (
	"context"
	"fmt"
	"path/filepath"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/pipeline"

	"github.com/Excoriate/terraform-registry-aws-rds/internal/tui"
	"github.com/Excoriate/terraform-registry-aws-rds/pkg/o11y"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	recipe   string // maps to the recipe in the /examples/<recipe>
	scenario string // maps to a config/<scenario>.tfvars per each recipe.
	all      bool
)

var Cmd = &cobra.Command{
	Use:   "tf",
	Short: "Run terraform CI Jobs using Dagger",
	Run: func(cmd *cobra.Command, args []string) {
		ctx := context.TODO()
		// Builder the logger.
		logger := o11y.NewLogger(o11y.LoggerOptions{
			EnableJSONHandler: true,
			EnableStdError:    true,
		})

		// Build the UX.
		ux := &struct {
			Msg   tui.MessageWriter
			Title tui.TitleWriter
		}{
			Msg:   tui.NewMessageWriter(),
			Title: tui.NewTitleWriter(),
		}

		ux.Title.ShowTitle("Terraform CI/CD")

		// Creating a new action (they can be 'N', depending on your needs)
		tfInitAction := pipeline.NewAction(ctx, logger)
		var tfInitActionOptions []pipeline.InitActionOptionsFunc
		// Define the options for the action
		tfInitActionWithName := tfInitAction.WithName("terraform init")
		tfInitActionWithContainer := tfInitAction.WithContainerImage("hashicorp/terraform:0.12.24")
		tfInitActionCommands := tfInitAction.WithCommands("ls -ltrah", "terraform")

		// Append the instructions to build the action.
		tfInitActionOptions = append(tfInitActionOptions,
			tfInitActionWithName,
			tfInitActionWithContainer,
			tfInitActionCommands)

		tfInit, err := tfInitAction.Build(tfInitActionOptions...)

		if err != nil {
			panic(err)
		}

		// Now, let's put these actions into a job that can run them.
		tfJob := pipeline.NewJob(ctx, logger)
		var tfJobOptions []pipeline.InitJobOptionsFunc
		tfJobOptionName := tfJob.WithName("Testing pipeline")
		tfJobActions := tfJob.WithActions(tfInit)
		tfJobOptions = append(tfJobOptions, tfJobOptionName, tfJobActions)
		tfJobBuilt, err := tfJob.Build(tfJobOptions...)

		if err != nil {
			panic(err)
		}

		// Now, let's put these jobs into a pipeline that can run them.
		// Creating a new pipeline builder (instance)
		pb := pipeline.NewPipeline(ctx, logger)
		pipeline, err := pb.Build(pb.WithJob(tfJobBuilt))
		if err != nil {
			panic(err)
		}

		_, _ = pipeline.Run()
	},
}

func ScanTFVarsInConfigFolder(baseDirPath, workdir string) ([]string, error) {
	configPath := filepath.Join(baseDirPath, "/", "config")
	configFiles, err := filepath.Glob(filepath.Join(configPath, "/", "*.tfvars"))
	if err != nil {
		return nil, fmt.Errorf("error getting the *.tfvars files in the config/ folder: %v", err)
	}

	var tfVarFiles []string
	for _, configFile := range configFiles {
		tfVarInDagger := filepath.Join(workdir, "config", filepath.Base(configFile))
		tfVarFiles = append(tfVarFiles, tfVarInDagger)
	}

	return tfVarFiles, nil
}

func AddFlags() {
	Cmd.PersistentFlags().StringVarP(&recipe, "recipe", "", "basic",
		"Recipe to run. By default, "+
			"it'll run the 'basic' recipe in the 'examples' folder.")

	Cmd.PersistentFlags().StringVarP(&scenario, "scenario", "", "fixtures",
		"Scenario to run. By default, "+
			"it'll run the 'fixtures' scenario in the 'config' folder.")

	Cmd.PersistentFlags().BoolVarP(&all, "all", "", false, "Run all recipes in the 'examples' folder.")

	_ = viper.BindPFlag("recipe", Cmd.PersistentFlags().Lookup("recipe"))
	_ = viper.BindPFlag("scenario", Cmd.PersistentFlags().Lookup("scenario"))
	_ = viper.BindPFlag("all", Cmd.PersistentFlags().Lookup("all"))

}
func init() {
	AddFlags()
}
