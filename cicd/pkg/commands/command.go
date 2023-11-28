package commands

import (
	"fmt"

	"github.com/Excoriate/terraform-registry-aws-rds/pkg/utils"
)

type Command struct {
	Binary                  string
	Command                 string
	Args                    []Args
	OmitBinaryNameInCommand bool
}

// Args represents a command-line argument, consisting of a Name and a Value.
type Args struct {
	Name  string
	Value string
}

// GetCommand returns the command as a slice of strings, ready to be executed.
func (c *Command) GetCommand() []string {
	var commandParts []string
	if !c.OmitBinaryNameInCommand {
		commandParts = append(commandParts, c.Binary)
	}
	commandParts = append(commandParts, c.Command)
	for _, arg := range c.Args {
		commandParts = append(commandParts, arg.Name)
		commandParts = append(commandParts, arg.Value)
	}
	return commandParts
}

// GetTerraformCommand creates a new Command struct for a Terraform command.
func GetTerraformCommand(command string, args []Args) Command {
	return Command{
		Binary:  "terraform",
		Command: command,
		Args:    args,
	}
}

// AddArgsToCommand adds a slice of Args to a Command struct.
func AddArgsToCommand(command Command, args []Args) (Command, error) {
	for _, arg := range args {
		if arg.Name == "" {
			return command, fmt.Errorf("the name of an argument cannot be empty in command %s", command.Command)
		}

		argValue := ""
		if arg.Value != "" {
			argValue = fmt.Sprintf("=%s", arg.Value)
		}

		command.Args = append(command.Args, Args{
			Name:  arg.Name,
			Value: argValue,
		})
	}

	return command, nil
}

// ConvertCommandToDaggerFormat converts a Command struct to a format suitable for Dagger's WithExec.
func ConvertCommandToDaggerFormat(cmd Command) [][]string {
	cleanedCommands := utils.CleanSliceFromValuesThatAreEmpty(cmd.GetCommand())
	return [][]string{cleanedCommands}
}
