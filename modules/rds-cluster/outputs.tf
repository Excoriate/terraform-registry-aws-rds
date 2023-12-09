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
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.id])
  description = "The primary cluster id of the RDS cluster."
}

output "primary_cluster_identifier" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.cluster_identifier])
  description = "The primary cluster identifier of the RDS cluster."
}

output "primary_cluster_endpoint" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.endpoint])
  description = "The primary cluster endpoint of the RDS cluster."
}

output "primary_database_name" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.database_name])
  description = "The primary database name of the RDS cluster."
}

output "primary_master_username" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.master_username])
  description = "The primary master username of the RDS cluster."
}

output "primary_master_password" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.master_password if c.master_password != null])
  description = "The primary master password of the RDS cluster."
  sensitive   = true
}

output "db_port" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.port])
  description = "The primary port of the RDS cluster."
}

output "primary_cluster_arn" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.arn])
  description = "The primary ARN of the RDS cluster."
}

output "primary_reader_endpoint" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.reader_endpoint])
  description = "The reader endpoint of the RDS cluster."
}

output "primary_security_groups" {
  value       = !local.is_enabled ? null : join("", [for c in aws_rds_cluster.primary : c.vpc_security_group_ids if c != null && c.vpc_security_group_ids != null])
  description = "The primary security groups of the RDS cluster."
}
