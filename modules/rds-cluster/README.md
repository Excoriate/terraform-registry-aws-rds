<!-- BEGIN_TF_DOCS -->
# ☁️ AWS RDS Cluster Module
## Description

This module is used to create an AWS RDS Cluster. The current capabilities are supported:
* 🚀 Create an AWS RDS Cluster
* 🚀 Create an AWS RDS Cluster Parameter Group
* 🚀 Create an AWS RDS Cluster Subnet Group

For more information about this specific resources, please visit its official documentation [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html).
For more information about the resource configuration using Terraform, please visit the official documentation [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster).

---
## Example
Examples of this module's usage are available in the [examples](./examples) folder.

```hcl
module "main_module" {
  source                                  = "../../../modules/rds-cluster"
  is_enabled                              = var.is_enabled
  cluster_config                          = var.cluster_config
  cluster_backup_config                   = var.cluster_backup_config
  cluster_change_management_config        = var.cluster_change_management_config
  cluster_replication_config              = var.cluster_replication_config
  cluster_storage_config                  = var.cluster_storage_config
  cluster_serverless_config               = var.cluster_serverless_config
  cluster_timeouts_config                 = var.cluster_timeouts_config
  cluster_iam_roles_config                = var.cluster_iam_roles_config
  cluster_subnet_group_config             = var.cluster_subnet_group_config
  cluster_security_groups_config          = var.cluster_security_groups_config
  cluster_security_groups_allowed_config  = var.cluster_security_groups_allowed_config
  cluster_restore_to_point_in_time_config = var.cluster_restore_to_point_in_time_config
  cluster_parameter_groups_config         = var.cluster_parameter_groups_config
  cluster_network_config                  = var.cluster_network_config
  tags                                    = var.tags
}
```

For module composition, It's recommended to take a look at the module's `outputs` to understand what's available:
```hcl
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

```

Recipes are included - Some of them are described as follows:
"Basic configuration" - This recipe is used to create a basic RDS Cluster.
```hcl
aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
}

cluster_backup_config = {
  cluster_identifier  = "test-cluster-1"
  skip_final_snapshot = true
}

```

With backup
```hcl
aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
}

cluster_backup_config = {
  cluster_identifier      = "test-cluster-1"
  skip_final_snapshot     = true
  backup_retention_period = 10
  preferred_backup_window = "07:00-09:00"
  backup_window           = "07:00-09:00"
  copy_tags_to_snapshot   = false
}

```

With change management-related configurations
```hcl
aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
}

cluster_backup_config = {
  cluster_identifier      = "test-cluster-1"
  skip_final_snapshot     = true
  preferred_backup_window = "01:00-03:00"
}

cluster_change_management_config = {
  cluster_identifier           = "test-cluster-1"
  apply_immediately            = true
  allow_major_version_upgrade  = true
  preferred_maintenance_window = "sun:07:00-sun:09:00"
}

```

With serverless-related configurations (for V1, and V2)
```hcl
aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
  engine_mode        = "provisioned"
}

cluster_backup_config = {
  cluster_identifier  = "test-cluster-1"
  skip_final_snapshot = true
}

cluster_serverless_config = {
  cluster_identifier   = "test-cluster-1"
  enable_http_endpoint = true
  scaling_configuration_for_v1 = {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 1
    seconds_until_auto_pause = 300
  }
}

```
```hcl
aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
  engine_mode        = "provisioned"
}

cluster_backup_config = {
  cluster_identifier  = "test-cluster-1"
  skip_final_snapshot = true
}

cluster_serverless_config = {
  cluster_identifier   = "test-cluster-1"
  enable_http_endpoint = true
  scaling_configuration_for_v2 = {
    max_capacity = 4
    min_capacity = 2
  }
}

```
And more. Check the [config](./examples/rds-cluster/basic/config) folder for more examples.


---

## Module's documentation
(This documentation is auto-generated using [terraform-docs](https://terraform-docs.io))
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.28.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.subnet_group_from_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_db_subnet_group.subnet_group_from_vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_inbound_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_inbound_traffic_from_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_inbound_traffic_from_database_members](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_inbound_traffic_from_security_group_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_outbound_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_subnets.fetch_subnets_by_vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc_from_vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.vpc_from_vpc_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 5.29.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0, < 3.6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_backup_config"></a> [cluster\_backup\_config](#input\_cluster\_backup\_config) | Cluster backup configurations to create. Each element of the list is an object that represents<br>  a cluster backup configuration. For more information about its validations, see the terraform aws\_rds\_cluster<br>  resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>  The current supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - backup\_retention\_period: (Optional) The days to retain backups for. Default 5<br>  - backup\_window: (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC<br>  - preferred\_backup\_window: (Optional) The daily time range during which automated backups are created if automated backups are enabled, using the BackupRetentionPeriod parameter. Must be in the format hh24:mi-hh24:mi. Must be at least 30 minutes.<br>  - skip\_final\_snapshot: (Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from FinalDBSnapshotIdentifier. Default is true.<br>  - final\_snapshot\_identifier: (Optional) The name of your final DB snapshot when this DB cluster is deleted. Must be provided if SkipFinalSnapshot is false.<br>  - copy\_tags\_to\_snapshot: (Optional) Copy all Cluster tags to snapshots. Default is false.<br>  - backtrack\_window: (Optional) The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0.<br>  - delete\_automatic\_backups: (Optional) Specifies whether to remove automated backups immediately after the DB cluster is deleted. Default is true. | <pre>object({<br>    cluster_identifier        = string<br>    backup_retention_period   = optional(number, 5)<br>    preferred_backup_window   = optional(string, "07:00-09:00")<br>    skip_final_snapshot       = optional(bool, true)<br>    final_snapshot_identifier = optional(string)<br>    copy_tags_to_snapshot     = optional(bool, false)<br>    backtrack_window          = optional(number, 0)<br>    delete_automatic_backups  = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_cluster_change_management_config"></a> [cluster\_change\_management\_config](#input\_cluster\_change\_management\_config) | Cluster change management configurations to create. This configuration encapsulates the<br>  changes that will be applied to the cluster. The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - apply\_immediately: (Optional) Indicates whether the modifications in this request and any pending modifications are asynchronously applied as soon as possible, regardless of the PreferredMaintenance Window setting for the DB cluster. If this parameter is set to false, changes to the DB cluster are applied during the next maintenance window. The ApplyImmediately parameter only affects the NewDBClusterIdentifier and MasterUserPassword values. If you set this parameter value to false, the changes to the NewDBClusterIdentifier and MasterUserPassword values are applied during the next maintenance window. All other changes are applied immediately, regardless of the value of the ApplyImmediately parameter. Default is false.<br>  - allow\_major\_version\_upgrade: (Optional) Indicates that major version upgrades are allowed. Changing this parameter doesn't result in an outage and the change is asynchronously applied as soon as possible. Constraints: This parameter must be set to true when specifying a value for the EngineVersion parameter that is a different major version than the DB cluster's current version.<br>  - preferred\_maintenance\_window: (Optional) The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). For more information, see Amazon RDS Maintenance Window. Format: ddd:hh24:mi-ddd:hh24:mi. Valid Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun. Constraints: Minimum 30-minute window.<br>  - deletion\_protection: (Optional) If the DB cluster is a read replica, then set this to true in order to prevent it from being deleted when it is identified by Terraform as a managed replica of another DB cluster. Defaults to false. | <pre>object({<br>    cluster_identifier           = string<br>    apply_immediately            = optional(bool, false)<br>    allow_major_version_upgrade  = optional(bool, false)<br>    preferred_maintenance_window = optional(string, "sun:05:00-sun:07:00")<br>    deletion_protection          = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Cluster configurations to create. Each element of the list is an object that represents<br>  a cluster configuration. For more information about its validations, see the terraform aws\_rds\_cluster<br>  resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>  The current supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - database\_name: (Optional) The name of the database to create when the DB instance is created.<br>  - master\_username: (Optional) Username for the master DB user. If omitted, Terraform will assign 'admin'<br>  - master\_password: (Optional) Password for the master DB user. If omitted, Terraform will generate a random, unique password.<br>  - engine: (Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora-postgresql<br>  - engine\_mode: (Optional) The database engine mode. Valid values: global, parallelquery, provisioned, serverless. Defaults to provisioned.<br>  - engine\_version: (Optional) The engine version to use. If left at the default, the latest engine version is used. If it changed, DB cluster will be recreated.<br>  - replication\_source\_identifier: (Optional) ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica.<br>  - snapshot\_identifier: (Optional) The identifier for a DB snapshot from which you want to restore the new DB cluster.<br>  - enabled\_cloudwatch\_logs\_exports: (Optional) List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql, upgrade<br>  - db\_cluster\_instance\_class: (Optional) The instance class to use. For details on CPU and memory, see Scaling Aurora PostgreSQL DB clusters. Defaults to db.r5.large.<br>  - is\_secondary: (Optional) Whether this cluster is the secondary cluster of a global database cluster or not. Default is false. | <pre>object({<br>    cluster_identifier              = string<br>    database_name                   = optional(string)<br>    master_username                 = optional(string, "goduser")<br>    master_password                 = optional(string)<br>    engine                          = optional(string, "aurora-postgresql")<br>    engine_mode                     = optional(string, "provisioned")<br>    engine_version                  = optional(string)<br>    replication_source_identifier   = optional(string)<br>    snapshot_identifier             = optional(string)<br>    enabled_cloudwatch_logs_exports = optional(list(string))<br>    db_cluster_instance_class       = optional(string)<br>    is_secondary                    = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_cluster_iam_roles_config"></a> [cluster\_iam\_roles\_config](#input\_cluster\_iam\_roles\_config) | Cluster configuration for IAM roles configurations to create. This configuration encapsulates the<br>necessary configuration for the IAM roles of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - iam\_roles: (Optional) A List of ARNs for the IAM roles to associate to the RDS Cluster.<br>  - iam\_database\_authentication\_enabled: (Optional) Whether to enable mapping of AWS Identity and Access Management (IAM) accounts to database accounts. Default is false. | <pre>object({<br>    cluster_identifier                  = string<br>    iam_roles                           = optional(list(string))<br>    iam_database_authentication_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_cluster_network_config"></a> [cluster\_network\_config](#input\_cluster\_network\_config) | Cluster configuration for network configurations to create. This configuration encapsulates the<br>necessary configuration for the network of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - network\_type: (Optional) The type of network to create. Valid values are IPV4, and DUAL. Default is IPV4.<br>  - additional\_security\_group\_ids: (Optional) A list of additional security group IDs to allow access to from the cluster. These sg's should be in the same VPC. Default is []. | <pre>object({<br>    cluster_identifier            = string<br>    network_type                  = optional(string, "IPV4")<br>    additional_security_group_ids = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_cluster_parameter_groups_config"></a> [cluster\_parameter\_groups\_config](#input\_cluster\_parameter\_groups\_config) | Cluster configuration for parameter groups configurations to create. This configuration encapsulates the<br>necessary configuration for the parameter groups of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - parameter\_group\_name: (Optional) The name of the DB parameter group to associate with this DB cluster.<br>  - parameter\_group\_family: (Optional) The family of the DB parameter group.<br>  - parameters: (Optional) A list of DB parameters to apply.<br>  - parameters.name: (Required) The name of the DB parameter.<br>  - parameters.value: (Required) The value of the DB parameter.<br>  - parameters.apply\_method: (Optional) Indicates when to apply parameter updates. Can be immediate or pending-reboot. Default is pending-reboot. | <pre>object({<br>    cluster_identifier     = string<br>    parameter_group_name   = optional(string)<br>    parameter_group_family = optional(string, "aurora.5.6")<br>    parameters = optional(list(object({<br>      name         = string<br>      value        = string<br>      apply_method = optional(string, "pending-reboot")<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_cluster_replication_config"></a> [cluster\_replication\_config](#input\_cluster\_replication\_config) | Cluster configuration for replication configurations to create. This configuration encapsulates the<br>necessary configuration for making this cluster a 'replica' or a 'secondary' of another cluster.<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - replication\_source\_identifier: (Optional) The Amazon Resource Name (ARN) of the source DB instance or DB cluster if this DB cluster is created as a read replica.<br>  - replication\_source\_region: (Optional) The region of the source DB instance or DB cluster if this DB cluster is created as a read replica.<br>  - enable\_global\_write\_forwarding: (Optional) Enable write forwarding for a cluster in a different region. Default is false.<br>  - global\_cluster\_identifier: (Optional) The global cluster identifier of an Aurora cluster that becomes the primary cluster in the new global database cluster. Works only<br>if this cluster is set to 'secondary', and the primary cluster is in a different region. | <pre>object({<br>    cluster_identifier             = string<br>    replication_source_identifier  = optional(string)<br>    replication_source_region      = optional(string)<br>    enable_global_write_forwarding = optional(bool, false)<br>    global_cluster_identifier      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_cluster_restore_to_point_in_time_config"></a> [cluster\_restore\_to\_point\_in\_time\_config](#input\_cluster\_restore\_to\_point\_in\_time\_config) | Cluster configuration for restore to point in time configurations to create. This configuration encapsulates the<br>necessary configuration for the restore to point in time of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - source\_cluster\_identifier: (Optional) The identifier of the source cluster from which to restore.<br>  - restore\_type: (Optional) The type of restore to be performed. Valid values are copy-on-write, which creates a new cluster from a snapshot and then restores data into it, and point-in-time, which restores data from an existing cluster into a new cluster based on the specified time. Default is copy-on-write.<br>  - use\_latest\_restorable\_time: (Optional) Specifies whether (true) or not (false) the DB cluster is restored from the latest backup time. Default is true. | <pre>object({<br>    cluster_identifier         = string<br>    source_cluster_identifier  = optional(string, "120m")<br>    restore_type               = optional(string, "copy-on-write")<br>    use_latest_restorable_time = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_cluster_security_groups_allowed_config"></a> [cluster\_security\_groups\_allowed\_config](#input\_cluster\_security\_groups\_allowed\_config) | Cluster configuration for security group configurations to create. This configuration encapsulates the<br>necessary configuration for the security groups of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - security\_group\_id: (Optional) A list of additional security group IDs to allow access to from the cluster. These sg's should be in the same VPC. Default is [].<br>  - db\_port: The port on which the DB accepts connections. Default is 5432.<br>  - vpc\_id: (Optional) The VPC ID. If the vpc\_name is provided, the module will use the vpc\_id of the vpc\_name.<br>  - vpc\_name: (Optional) The VPC name. If the vpc\_id is provided, the module will use the vpc\_id. | <pre>list(object({<br>    cluster_identifier = string<br>    security_group_id  = string<br>    db_port            = number<br>    vpc_id             = optional(string)<br>    vpc_name           = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_cluster_security_groups_config"></a> [cluster\_security\_groups\_config](#input\_cluster\_security\_groups\_config) | Cluster configuration for security group configurations to create. This configuration encapsulates the<br>necessary configuration for the security groups of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - vpc\_id: (Optional) The VPC ID. If the vpc\_name is provided, the module will use the vpc\_id of the vpc\_name.<br>  - vpc\_name: (Optional) The VPC name. If the vpc\_id is provided, the module will use the vpc\_id.<br>  - allow\_traffic\_from\_database\_members: (Optional) Whether to allow traffic from the database members or not. Default is false.<br>  - allow\_traffic\_from\_CIDR\_blocks: (Optional) A list of CIDR blocks to allow traffic from.<br>  - allow\_all\_outbound\_traffic: (Optional) Whether to allow all outbound traffic or not. Default is false.<br>  - allow\_all\_inbound\_traffic: (Optional) Whether to allow all inbound traffic or not. Default is false. Not recommended.<br>For more information about how security groups works in the context of RDS, and Aurora specifically, see the AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.html<br>  - db\_port: The port on which the DB accepts connections. Default is 5432. | <pre>object({<br>    cluster_identifier                  = string<br>    vpc_id                              = optional(string)<br>    vpc_name                            = optional(string)<br>    allow_traffic_from_database_members = optional(bool, false)<br>    allow_traffic_from_cidr_blocks      = optional(list(string))<br>    allow_all_outbound_traffic          = optional(bool, false)<br>    allow_all_inbound_traffic           = optional(bool, false)<br>    db_port                             = number<br>  })</pre> | `null` | no |
| <a name="input_cluster_serverless_config"></a> [cluster\_serverless\_config](#input\_cluster\_serverless\_config) | Cluster configuration for serverless configurations to create. This configuration encapsulates the<br>necessary configuration for the serverless cluster. It also manages the scaling configuration<br>for the cluster (serverlessv2). For more information about its validations, see the terraform aws\_rds\_cluster<br>resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster and the related AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - enable\_http\_endpoint: (Optional) Enable HTTP endpoint (data API). Only valid when engine\_mode is set to serverless.<br>  - scaling\_configuration\_for\_v2: (Optional) Nested argument defining scaling configuration for the Aurora Serverless cluster. Defined below.<br>  - scaling\_configuration.max\_capacity: (Optional) The maximum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.<br>  - scaling\_configuration.min\_capacity: (Optional) The minimum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.<br>  - scaling\_configuration\_for\_v1: (Optional) Nested argument defining scaling configuration for the Aurora Serverless cluster. Defined below.<br>  - scaling\_configuration.auto\_pause: (Optional) Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it.<br>  - scaling\_configuration.max\_capacity: (Optional) The maximum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.<br>  - scaling\_configuration.min\_capacity: (Optional) The minimum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.<br>  - scaling\_configuration.seconds\_until\_auto\_pause: (Optional) The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400. The default is 300.<br>  - scaling\_configuration.timeout\_action: (Optional) The action to take when the timeout is reached, either ForceApplyCapacityChange or RollbackCapacityChange. The default is RollbackCapacityChange. | <pre>object({<br>    cluster_identifier   = string<br>    enable_http_endpoint = optional(bool, false)<br>    scaling_configuration_for_v2 = optional(object({<br>      max_capacity = optional(number, 2)<br>      min_capacity = optional(number, 2)<br>    }))<br>    scaling_configuration_for_v1 = optional(object({<br>      auto_pause               = optional(bool, true)<br>      max_capacity             = optional(number, 2)<br>      min_capacity             = optional(number, 2)<br>      seconds_until_auto_pause = optional(number, 300)<br>      timeout_action           = optional(string, "ForceApplyCapacityChange")<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_cluster_storage_config"></a> [cluster\_storage\_config](#input\_cluster\_storage\_config) | Cluster configuration for storage configurations to create. This configuration encapsulates the<br>necessary configuration for the storage of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster and the related AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - storage\_encrypted: (Optional) Specifies whether the DB cluster is encrypted. The default is false.<br>  - storage\_type: (Optional) One of "standard" (magnetic), "gp2" (general purpose SSD), or "io1" (provisioned IOPS SSD). The default is "gp2".<br>  - iops: (Optional) The amount of provisioned IOPS. Setting this implies a storage\_type of "io1".<br>  - allocated\_storage: (Optional) The allocated storage in gibibytes. If max\_allocated\_storage is configured, this argument represents the initial storage allocation and differences from the configured value will result in an outage. This argument is only available on DB instances supporting storage autoscaling.<br>  - kms\_key\_id: (Optional) The ARN for the KMS encryption key. When specifying kms\_key\_id, storage\_encrypted needs to be set to true. | <pre>object({<br>    cluster_identifier = string<br>    storage_encrypted  = optional(bool, false)<br>    storage_type       = optional(string, "gp2")<br>    iops               = optional(number)<br>    allocated_storage  = optional(number)<br>    kms_key_id         = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_cluster_subnet_group_config"></a> [cluster\_subnet\_group\_config](#input\_cluster\_subnet\_group\_config) | Cluster configuration for subnet group configurations to create. It works by either passing a list of subnet ids or a vpc id, from<br>  which the module will create a subnet group with all the subnets in the vpc. For more information about its validations,<br>  see the terraform aws\_db\_subnet\_group resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group<br>  The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - subnet\_ids: (Optional) A list of VPC subnet IDs. If the VPC ID is provided, the module will create a subnet group with all the subnets in the VPC.<br>  - subnet\_group\_name: (Optional) The name of the DB subnet group. If omitted, Terraform will assign a random, unique name.<br>  - vpc\_id: (Optional) The VPC ID. If the subnet\_ids are provided, the module will create a subnet group with all the subnets in the VPC.<br>The precedence order is: Subnet\_group\_name > Subnet\_ids > Vpc\_id | <pre>object({<br>    cluster_identifier = string<br>    subnet_ids         = optional(list(string))<br>    subnet_group_name  = optional(string)<br>    vpc_id             = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_cluster_timeouts_config"></a> [cluster\_timeouts\_config](#input\_cluster\_timeouts\_config) | Cluster configuration for timeouts configurations to create. This configuration encapsulates the<br>necessary configuration for the timeouts of the cluster. For more information about its validations,<br>see the terraform aws\_rds\_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster<br>The supported attributes are:<br>  - cluster\_identifier: (Required) The cluster identifier.<br>  - create: (Optional) Time to wait for the cluster to be created. Defaults to 30 minutes.<br>  - delete: (Optional) Time to wait for the cluster to be deleted. Defaults to 30 minutes.<br>  - update: (Optional) Time to wait for the cluster to be updated. Defaults to 30 minutes. | <pre>object({<br>    cluster_identifier = string<br>    create             = optional(string, "30m")<br>    delete             = optional(string, "30m")<br>    update             = optional(string, "30m")<br>  })</pre> | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_port"></a> [db\_port](#output\_db\_port) | The primary port of the RDS cluster. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_primary_cluster_arn"></a> [primary\_cluster\_arn](#output\_primary\_cluster\_arn) | The primary ARN of the RDS cluster. |
| <a name="output_primary_cluster_endpoint"></a> [primary\_cluster\_endpoint](#output\_primary\_cluster\_endpoint) | The primary cluster endpoint of the RDS cluster. |
| <a name="output_primary_cluster_id"></a> [primary\_cluster\_id](#output\_primary\_cluster\_id) | The primary cluster id of the RDS cluster. |
| <a name="output_primary_cluster_identifier"></a> [primary\_cluster\_identifier](#output\_primary\_cluster\_identifier) | The primary cluster identifier of the RDS cluster. |
| <a name="output_primary_database_name"></a> [primary\_database\_name](#output\_primary\_database\_name) | The primary database name of the RDS cluster. |
| <a name="output_primary_master_password"></a> [primary\_master\_password](#output\_primary\_master\_password) | The primary master password of the RDS cluster. |
| <a name="output_primary_master_username"></a> [primary\_master\_username](#output\_primary\_master\_username) | The primary master username of the RDS cluster. |
| <a name="output_primary_parameter_group_name"></a> [primary\_parameter\_group\_name](#output\_primary\_parameter\_group\_name) | The primary parameter group name of the RDS cluster. |
| <a name="output_primary_reader_endpoint"></a> [primary\_reader\_endpoint](#output\_primary\_reader\_endpoint) | The reader endpoint of the RDS cluster. |
| <a name="output_primary_security_groups"></a> [primary\_security\_groups](#output\_primary\_security\_groups) | The primary security groups of the RDS cluster. |
| <a name="output_primary_subnet_group_name"></a> [primary\_subnet\_group\_name](#output\_primary\_subnet\_group\_name) | The primary subnet group name of the RDS cluster. |
| <a name="output_secondary_cluster_arn"></a> [secondary\_cluster\_arn](#output\_secondary\_cluster\_arn) | The secondary ARN of the RDS cluster. |
| <a name="output_secondary_cluster_endpoint"></a> [secondary\_cluster\_endpoint](#output\_secondary\_cluster\_endpoint) | The secondary cluster endpoint of the RDS cluster. |
| <a name="output_secondary_cluster_id"></a> [secondary\_cluster\_id](#output\_secondary\_cluster\_id) | The secondary cluster id of the RDS cluster. |
| <a name="output_secondary_cluster_identifier"></a> [secondary\_cluster\_identifier](#output\_secondary\_cluster\_identifier) | The secondary cluster identifier of the RDS cluster. |
| <a name="output_secondary_database_name"></a> [secondary\_database\_name](#output\_secondary\_database\_name) | The secondary database name of the RDS cluster. |
| <a name="output_secondary_master_password"></a> [secondary\_master\_password](#output\_secondary\_master\_password) | The secondary master password of the RDS cluster. |
| <a name="output_secondary_master_username"></a> [secondary\_master\_username](#output\_secondary\_master\_username) | The secondary master username of the RDS cluster. |
| <a name="output_secondary_parameter_group_name"></a> [secondary\_parameter\_group\_name](#output\_secondary\_parameter\_group\_name) | The secondary parameter group name of the RDS cluster. |
| <a name="output_secondary_reader_endpoint"></a> [secondary\_reader\_endpoint](#output\_secondary\_reader\_endpoint) | The secondary reader endpoint of the RDS cluster. |
| <a name="output_secondary_security_groups"></a> [secondary\_security\_groups](#output\_secondary\_security\_groups) | The secondary security groups of the RDS cluster. |
| <a name="output_secondary_subnet_group_name"></a> [secondary\_subnet\_group\_name](#output\_secondary\_subnet\_group\_name) | The secondary subnet group name of the RDS cluster. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
<!-- END_TF_DOCS -->
