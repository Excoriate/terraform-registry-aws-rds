output "is_enabled" {
  value       = module.main_module.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = module.main_module.tags_set
  description = "The tags set for the module."
}

## ---------------------------------------------------------------------------------------------------------------------
## OUTPUT-MY-INPUT pattern
## Useful to show what's entered as input, and help in troubleshooting.
## ---------------------------------------------------------------------------------------------------------------------
output "vpc_config_inputs" {
  value       = module.main_module.vpc_config_inputs
  description = "The VPC configuration inputs."
}

output "rules_config_inputs" {
  value       = module.main_module.rules_config_inputs
  description = "The rules configuration inputs."
}


## ---------------------------------------------------------------------------------------------------------------------
## OUTPUTS - MODULE
## This section contains all the outputs of the module.
## ---------------------------------------------------------------------------------------------------------------------
output "security_group_id" {
  value       = module.main_module.security_group_id
  description = "The ID of the security group."
}

output "security_group_arn" {
  value       = module.main_module.security_group_arn
  description = "The ARN of the security group."
}

output "vpc_from_id" {
  value       = module.main_module.vpc_from_id
  description = "VPC configuration if it's fetched by id."
}

output "vpc_from_name" {
  value       = module.main_module.vpc_from_name
  description = "VPC configuration if it's fetched by name."
}
