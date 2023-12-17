## ---------------------------------------------------------------------------------------------------------------------
## GENERAL-PURPOSE OUTPUTS
## This section contains all the general-purpose outputs of the module.
## ---------------------------------------------------------------------------------------------------------------------
output "is_enabled" {
  value       = var.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = var.tags
  description = "The tags set for the module."
}

## ---------------------------------------------------------------------------------------------------------------------
## OUTPUT-MY-INPUT pattern
## Useful to show what's entered as input, and help in troubleshooting.
## ---------------------------------------------------------------------------------------------------------------------
output "vpc_config_inputs" {
  value = {
    raw        = var.vpc_config
    normalised = local.vpc_config_normalised
    created    = local.vpc_config_create
  }
  description = "The VPC configuration inputs."
}

output "rules_config_inputs" {
  value = {
    raw        = var.security_group_config
    normalised = local.sg_config_normalised
    created    = local.sg_config_create
  }
  description = "The rules configuration inputs."
}


## ---------------------------------------------------------------------------------------------------------------------
## OUTPUTS - MODULE
## This section contains all the outputs of the module.
## ---------------------------------------------------------------------------------------------------------------------
output "security_group_id" {
  value       = join("", [for security_group in aws_security_group.this : security_group.id])
  description = "The ID of the security group."
}

output "security_group_arn" {
  value       = join("", [for security_group in aws_security_group.this : security_group.arn])
  description = "The ARN of the security group."
}

output "vpc_from_id" {
  value       = [for vpc in data.aws_vpc.sg_vpc_by_id : vpc if vpc != null]
  description = "VPC configuration if it's fetched by id."
}

output "vpc_from_name" {
  value       = [for vpc in data.aws_vpc.sg_vpc_by_name : vpc if vpc != null]
  description = "VPC configuration if it's fetched by name."
}
