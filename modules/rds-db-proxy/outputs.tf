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
output "proxy_ids" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy.this : out.id if out != null]
  description = "The proxy IDs."
}

output "proxy_arns" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy.this : out.arn if out != null]
  description = "The proxy ARNs."
}

output "proxy_iam_role_arns" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy.this : out.role_arn if out != null]
  description = "The proxy IAM role ARNs."
}

output "proxy_endpoints" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy.this : out.endpoint if out != null]
  description = "The proxy endpoints."
}

output "proxy_target_group_arns" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_default_target_group.this : out.arn if out != null]
  description = "The proxy target group ARNs."
}

output "proxy_target_group_names" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_default_target_group.this : out.name if out != null]
  description = "The proxy target group names."
}

output "proxy_target_group_ids" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_default_target_group.this : out.id if out != null]
  description = "The proxy target group IDs."
}

output "proxy_target_rds_resource_ids" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_target.this : out.rds_resource_id if out != null]
  description = "The proxy target RDS resource IDs."
}

output "proxy_target_ids" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_target.this : out.id if out != null]
  description = "The proxy target IDs."
}

output "proxy_target_endpoint" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_target.this : out.endpoint if out != null]
  description = "The proxy target endpoints."
}

output "proxy_target_port" {
  value       = !local.is_enabled ? [] : [for out in aws_db_proxy_target.this : out.port if out != null]
  description = "The proxy target ports."
}
