variable "is_enabled" {
  description = "Enable or disable the module"
  type        = bool
}

###################################
# AWS and provider's specific configuration
###################################
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy to"
}
