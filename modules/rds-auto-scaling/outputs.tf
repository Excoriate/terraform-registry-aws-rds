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

/*
-------------------------------------
Custom outputs
-------------------------------------
*/
// FIXME: Remove, refactor or change. (Template)
