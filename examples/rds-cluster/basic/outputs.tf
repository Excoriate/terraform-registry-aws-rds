output "is_enabled" {
  value       = module.main_module.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = module.main_module.tags_set
  description = "The tags set for the module."
}

output "primary_cluster_id" {
  value       = module.main_module.primary_cluster_id
  description = "The primary cluster id of the RDS cluster."
}

output "primary_cluster_identifier" {
  value       = module.main_module.primary_cluster_identifier
  description = "The primary cluster identifier of the RDS cluster."
}

output "primary_cluster_endpoint" {
  value       = module.main_module.primary_cluster_endpoint
  description = "The primary cluster endpoint of the RDS cluster."
}

output "primary_database_name" {
  value       = module.main_module.primary_database_name
  description = "The primary database name of the RDS cluster."
}

output "primary_master_username" {
  value       = module.main_module.primary_master_username
  description = "The primary master username of the RDS cluster."
}

output "primary_master_password" {
  value       = module.main_module.primary_master_password
  description = "The primary master password of the RDS cluster."
  sensitive   = true
}

output "db_port" {
  value       = module.main_module.db_port
  description = "The primary port of the RDS cluster."
}

output "primary_cluster_arn" {
  value       = module.main_module.primary_cluster_arn
  description = "The primary ARN of the RDS cluster."
}

output "primary_reader_endpoint" {
  value       = module.main_module.primary_reader_endpoint
  description = "The reader endpoint of the RDS cluster."
}

output "primary_security_groups" {
  value       = module.main_module.primary_security_groups
  description = "The primary security groups of the RDS cluster."
}

output "primary_subnet_group_name" {
  value       = module.main_module.primary_subnet_group_name
  description = "The primary subnet group name of the RDS cluster."
}

output "primary_parameter_group_name" {
  value       = module.main_module.primary_parameter_group_name
  description = "The primary parameter group name of the RDS cluster."
}

output "secondary_cluster_id" {
  value       = module.main_module.secondary_cluster_id
  description = "The secondary cluster id of the RDS cluster."
}

output "secondary_cluster_identifier" {
  value       = module.main_module.secondary_cluster_identifier
  description = "The secondary cluster identifier of the RDS cluster."
}

output "secondary_cluster_endpoint" {
  value       = module.main_module.secondary_cluster_endpoint
  description = "The secondary cluster endpoint of the RDS cluster."
}

output "secondary_database_name" {
  value       = module.main_module.secondary_database_name
  description = "The secondary database name of the RDS cluster."
}

output "secondary_master_username" {
  value       = module.main_module.secondary_master_username
  description = "The secondary master username of the RDS cluster."
}

output "secondary_master_password" {
  value       = module.main_module.secondary_master_password
  description = "The secondary master password of the RDS cluster."
  sensitive   = true
}

output "secondary_cluster_arn" {
  value       = module.main_module.secondary_cluster_arn
  description = "The secondary ARN of the RDS cluster."
}

output "secondary_reader_endpoint" {
  value       = module.main_module.secondary_reader_endpoint
  description = "The secondary reader endpoint of the RDS cluster."
}

output "secondary_security_groups" {
  value       = module.main_module.secondary_security_groups
  description = "The secondary security groups of the RDS cluster."
}

output "secondary_subnet_group_name" {
  value       = module.main_module.secondary_subnet_group_name
  description = "The secondary subnet group name of the RDS cluster."
}

output "secondary_parameter_group_name" {
  value       = module.main_module.secondary_parameter_group_name
  description = "The secondary parameter group name of the RDS cluster."
}
