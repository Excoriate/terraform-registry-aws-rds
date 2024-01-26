output "is_enabled" {
  value       = module.main_module.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = module.main_module.tags_set
  description = "The tags set for the module."
}

output "proxy_ids" {
  value       = module.main_module.proxy_ids
  description = "The proxy IDs."
}

output "proxy_arns" {
  value       = module.main_module.proxy_arns
  description = "The proxy ARNs."
}

output "proxy_iam_role_arns" {
  value       = module.main_module.proxy_iam_role_arns
  description = "The proxy IAM role ARNs."
}

output "proxy_endpoints" {
  value       = module.main_module.proxy_endpoints
  description = "The proxy endpoints."
}

output "proxy_target_group_arns" {
  value       = module.main_module.proxy_target_group_arns
  description = "The proxy target group ARNs."
}

output "proxy_target_group_names" {
  value       = module.main_module.proxy_target_group_names
  description = "The proxy target group names."
}

output "proxy_target_group_ids" {
  value       = module.main_module.proxy_target_group_ids
  description = "The proxy target group IDs."
}

output "proxy_target_rds_resource_ids" {
  value       = module.main_module.proxy_target_rds_resource_ids
  description = "The proxy target RDS resource IDs."
}

output "proxy_target_ids" {
  value       = module.main_module.proxy_target_ids
  description = "The proxy target IDs."
}

output "proxy_target_endpoint" {
  value       = module.main_module.proxy_target_endpoint
  description = "The proxy target endpoints."
}

output "proxy_target_port" {
  value       = module.main_module.proxy_target_port
  description = "The proxy target ports."
}
