## ---------------------------------------------------------------------------------------------------------------------
## GENERAL-PURPOSE INPUT VARIABLES
## These variables have general purpose and are used to configure the module execution
## ---------------------------------------------------------------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = <<EOF
  Whether this module will be created or not. It is useful, for stack-composite
modules that conditionally includes resources provided by this module..
EOF
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}

## ---------------------------------------------------------------------------------------------------------------------
## PROVIDER-SPECIFIC INPUT VARIABLES
## These variables are used to configure the provider-specific resources
## ---------------------------------------------------------------------------------------------------------------------
