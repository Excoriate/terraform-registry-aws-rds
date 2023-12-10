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
output "primary_cluster_id" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.id if cluster.id != null])
  description = "The primary cluster id of the RDS cluster."
}

output "primary_cluster_identifier" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.cluster_identifier if cluster.cluster_identifier != null])
  description = "The primary cluster identifier of the RDS cluster."
}

output "primary_cluster_endpoint" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.endpoint if cluster.endpoint != null])
  description = "The primary cluster endpoint of the RDS cluster."
}

output "primary_database_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.database_name if cluster.database_name != null])
  description = "The primary database name of the RDS cluster."
}

output "primary_master_username" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.master_username if cluster.master_username != null])
  description = "The primary master username of the RDS cluster."
}

output "primary_master_password" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.master_password if cluster.master_password != null])
  description = "The primary master password of the RDS cluster."
  sensitive   = true
}

output "db_port" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.port if cluster.port != null])
  description = "The primary port of the RDS cluster."
}

output "primary_cluster_arn" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.arn if cluster.arn != null])
  description = "The primary ARN of the RDS cluster."
}

output "primary_reader_endpoint" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.reader_endpoint if cluster.reader_endpoint != null])
  description = "The reader endpoint of the RDS cluster."
}

output "primary_security_groups" {
  value       = !local.is_enabled ? null : try(join("", [for cluster in aws_rds_cluster.primary : cluster.vpc_security_group_ids if cluster.vpc_security_group_ids != null]), null)
  description = "The primary security groups of the RDS cluster."
}

output "primary_subnet_group_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.primary : cluster.db_subnet_group_name if cluster.db_subnet_group_name != null])
  description = "The primary subnet group name of the RDS cluster."
}

output "primary_parameter_group_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster_parameter_group.this : cluster.name if cluster.name != null])
  description = "The primary parameter group name of the RDS cluster."
}

output "secondary_cluster_id" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.id if cluster.id != null])
  description = "The secondary cluster id of the RDS cluster."
}

output "secondary_cluster_identifier" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.cluster_identifier if cluster.cluster_identifier != null])
  description = "The secondary cluster identifier of the RDS cluster."
}

output "secondary_cluster_endpoint" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.endpoint if cluster.endpoint != null])
  description = "The secondary cluster endpoint of the RDS cluster."
}

output "secondary_database_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.database_name if cluster.database_name != null])
  description = "The secondary database name of the RDS cluster."
}

output "secondary_master_username" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.master_username if cluster.master_username != null])
  description = "The secondary master username of the RDS cluster."
}

output "secondary_master_password" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.master_password if cluster.master_password != null])
  description = "The secondary master password of the RDS cluster."
  sensitive   = true
}

output "secondary_cluster_arn" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.arn if cluster.arn != null])
  description = "The secondary ARN of the RDS cluster."
}

output "secondary_reader_endpoint" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.reader_endpoint if cluster.reader_endpoint != null])
  description = "The secondary reader endpoint of the RDS cluster."
}

output "secondary_security_groups" {
  value       = !local.is_enabled ? null : try(join("", [for cluster in aws_rds_cluster.secondary : cluster.vpc_security_group_ids if cluster.vpc_security_group_ids != null]), null)
  description = "The secondary security groups of the RDS cluster."
}

output "secondary_subnet_group_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster.secondary : cluster.db_subnet_group_name if cluster.db_subnet_group_name != null])
  description = "The secondary subnet group name of the RDS cluster."
}

output "secondary_parameter_group_name" {
  value       = !local.is_enabled ? null : join("", [for cluster in aws_rds_cluster_parameter_group.this : cluster.name if cluster.name != null])
  description = "The secondary parameter group name of the RDS cluster."
}
