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

###################################
# AWS and provider's specific configuration
###################################
#variable "aws_region" {
#  type        = string
#  default     = "us-east-1"
#  description = "AWS region to deploy to"
#}
