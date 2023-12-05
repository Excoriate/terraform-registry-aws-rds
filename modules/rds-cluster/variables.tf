variable "is_enabled" {
  type        = bool
  description = <<EOF
  Whether this module will be created or not. It is useful, for stack-composite
modules that conditionally includes resources provided by this module..
EOF
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}

###################################
# AWS and provider's specific configuration
###################################
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy to"
}

###################################
# Specific for this module
###################################
variable "cluster_config" {
  type = list(object({
    cluster_identifier              = string
    database_name                   = optional(string)
    master_username                 = optional(string, "goduser")
    master_password                 = optional(string)
    engine                          = optional(string, "aurora-postgresql")
    engine_mode                     = optional(string, "provisioned")
    engine_version                  = optional(string)
    replication_source_identifier   = optional(string)
    snapshot_identifier             = optional(string)
    enabled_cloudwatch_logs_exports = optional(list(string))
  }))
  default     = null
  description = <<EOF
  List of cluster configurations to create. Each element of the list is an object that represents
  a cluster configuration. For more information about its validations, see the terraform aws_rds_cluster
  resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
  The current supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - database_name: (Optional) The name of the database to create when the DB instance is created.
  - master_username: (Optional) Username for the master DB user. If omitted, Terraform will assign 'admin'
  - master_password: (Optional) Password for the master DB user. If omitted, Terraform will generate a random, unique password.
  - engine: (Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora-postgresql
  - engine_mode: (Optional) The database engine mode. Valid values: global, parallelquery, provisioned, serverless. Defaults to provisioned.
  - engine_version: (Optional) The engine version to use. If left at the default, the latest engine version is used. If it changed, DB cluster will be recreated.
  - replication_source_identifier: (Optional) ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica.
  - snapshot_identifier: (Optional) The identifier for a DB snapshot from which you want to restore the new DB cluster.
  - enabled_cloudwatch_logs_exports: (Optional) List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql, upgrade
EOF
}

variable "cluster_backup_config" {
  type = list(object({
    cluster_identifier        = string
    backup_retention_period   = optional(number, 5)
    preferred_backup_window   = optional(string, "07:00-09:00")
    skip_final_snapshot       = optional(bool, true)
    final_snapshot_identifier = optional(string)
    copy_tags_to_snapshot     = optional(bool, false)
    backtrack_window          = optional(number, 0)
    delete_automatic_backups  = optional(bool, false)
  }))
  description = <<EOF
  List of cluster backup configurations to create. Each element of the list is an object that represents
  a cluster backup configuration. For more information about its validations, see the terraform aws_rds_cluster
  resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
  The current supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - backup_retention_period: (Optional) The days to retain backups for. Default 5
  - backup_window: (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC
  - preferred_backup_window: (Optional) The daily time range during which automated backups are created if automated backups are enabled, using the BackupRetentionPeriod parameter. Must be in the format hh24:mi-hh24:mi. Must be at least 30 minutes.
  - skip_final_snapshot: (Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from FinalDBSnapshotIdentifier. Default is true.
  - final_snapshot_identifier: (Optional) The name of your final DB snapshot when this DB cluster is deleted. Must be provided if SkipFinalSnapshot is false.
  - copy_tags_to_snapshot: (Optional) Copy all Cluster tags to snapshots. Default is false.
  - backtrack_window: (Optional) The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0.
  - delete_automatic_backups: (Optional) Specifies whether to remove automated backups immediately after the DB cluster is deleted. Default is true.
EOF
  default     = null
}

variable "cluster_change_management_config" {
  type = list(object({
    cluster_identifier          = string
    apply_immediately           = optional(bool, false)
    allow_major_version_upgrade = optional(bool, false)
    maintenance_window          = optional(string, "sun:05:00-sun:07:00")
    deletion_protection         = optional(bool, false)
  }))
  description = <<EOF
  List of cluster change management configurations to create. This configuration encapsulates the
  changes that will be applied to the cluster. The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - apply_immediately: (Optional) Indicates whether the modifications in this request and any pending modifications are asynchronously applied as soon as possible, regardless of the PreferredMaintenanceWindow setting for the DB cluster. If this parameter is set to false, changes to the DB cluster are applied during the next maintenance window. The ApplyImmediately parameter only affects the NewDBClusterIdentifier and MasterUserPassword values. If you set this parameter value to false, the changes to the NewDBClusterIdentifier and MasterUserPassword values are applied during the next maintenance window. All other changes are applied immediately, regardless of the value of the ApplyImmediately parameter. Default is false.
  - allow_major_version_upgrade: (Optional) Indicates that major version upgrades are allowed. Changing this parameter doesn't result in an outage and the change is asynchronously applied as soon as possible. Constraints: This parameter must be set to true when specifying a value for the EngineVersion parameter that is a different major version than the DB cluster's current version.
  - maintenance_window: (Optional) The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). For more information, see Amazon RDS Maintenance Window. Format: ddd:hh24:mi-ddd:hh24:mi. Valid Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun. Constraints: Minimum 30-minute window.
  - deletion_protection: (Optional) If the DB cluster is a read replica, then set this to true in order to prevent it from being deleted when it is identified by Terraform as a managed replica of another DB cluster. Defaults to false.
EOF
  default     = null
}

variable "cluster_replication_config" {
  type = list(object({
    cluster_identifier             = string
    replication_source_identifier  = optional(string)
    replication_source_region      = optional(string)
    enable_global_write_forwarding = optional(bool, false)
  }))
  description = <<EOF
  List of cluster replication configurations to create. This configuration encapsulates the
necessary configuration for making this cluster a 'replica' or a 'secondary' of another cluster.
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - replication_source_identifier: (Optional) The Amazon Resource Name (ARN) of the source DB instance or DB cluster if this DB cluster is created as a read replica.
  - replication_source_region: (Optional) The region of the source DB instance or DB cluster if this DB cluster is created as a read replica.
  - enable_global_write_forwarding: (Optional) Enable write forwarding for a cluster in a different region. Default is false.
EOF
  default     = null
}

variable "cluster_storage_config" {
  type = list(object({
    cluster_identifier = string
    storage_encrypted  = optional(bool, false)
    storage_type       = optional(string, "gp2")
    iops               = optional(number)
    allocated_storage  = optional(number)
    kms_key_id         = optional(string)
  }))
  default     = null
  description = <<EOF
  List of cluster storage configurations to create. This configuration encapsulates the
necessary configuration for the storage of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster and the related AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - storage_encrypted: (Optional) Specifies whether the DB cluster is encrypted. The default is false.
  - storage_type: (Optional) One of "standard" (magnetic), "gp2" (general purpose SSD), or "io1" (provisioned IOPS SSD). The default is "gp2".
  - iops: (Optional) The amount of provisioned IOPS. Setting this implies a storage_type of "io1".
  - allocated_storage: (Optional) The allocated storage in gibibytes. If max_allocated_storage is configured, this argument represents the initial storage allocation and differences from the configured value will result in an outage. This argument is only available on DB instances supporting storage autoscaling.
  - kms_key_id: (Optional) The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true.
EOF
}

variable "cluster_serverless_config" {
  type = list(object({
    cluster_identifier   = string
    enable_http_endpoint = optional(bool, false)
    scaling_configuration_for_v2 = optional(object({
      max_capacity = optional(number, 2)
      min_capacity = optional(number, 2)
    }))
    scaling_configuration_for_v1 = optional(object({
      auto_pause               = optional(bool, true)
      max_capacity             = optional(number, 2)
      min_capacity             = optional(number, 2)
      seconds_until_auto_pause = optional(number, 300)
      timeout_action           = optional(string, "ForceApplyCapacityChange")
    }))
  }))
  default     = null
  description = <<EOF
  List of cluster serverless configurations to create. This configuration encapsulates the
necessary configuration for the serverless cluster. It also manages the scaling configuration
for the cluster (serverlessv2). For more information about its validations, see the terraform aws_rds_cluster
resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster and the related AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - enable_http_endpoint: (Optional) Enable HTTP endpoint (data API). Only valid when engine_mode is set to serverless.
  - scaling_configuration_for_v2: (Optional) Nested argument defining scaling configuration for the Aurora Serverless cluster. Defined below.
  - scaling_configuration.max_capacity: (Optional) The maximum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.
  - scaling_configuration.min_capacity: (Optional) The minimum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.
  - scaling_configuration_for_v1: (Optional) Nested argument defining scaling configuration for the Aurora Serverless cluster. Defined below.
  - scaling_configuration.auto_pause: (Optional) Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it.
  - scaling_configuration.max_capacity: (Optional) The maximum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.
  - scaling_configuration.min_capacity: (Optional) The minimum capacity for an Aurora DB cluster in serverless DB engine mode. Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256. The default is 2.
  - scaling_configuration.seconds_until_auto_pause: (Optional) The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400. The default is 300.
  - scaling_configuration.timeout_action: (Optional) The action to take when the timeout is reached, either ForceApplyCapacityChange or RollbackCapacityChange. The default is RollbackCapacityChange.
EOF
}

variable "cluster_timeouts_config" {
  type = list(object({
    cluster_identifier = string
    create             = optional(string, "60m")
    delete             = optional(string, "60m")
    update             = optional(string, "60m")
  }))
  default     = null
  description = <<EOF
  List of cluster timeouts configurations to create. This configuration encapsulates the
necessary configuration for the timeouts of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - create: (Optional) Time to wait for the cluster to be created. Defaults to 60 minutes.
  - delete: (Optional) Time to wait for the cluster to be deleted. Defaults to 60 minutes.
  - update: (Optional) Time to wait for the cluster to be updated. Defaults to 60 minutes.
EOF
}

variable "cluster_iam_roles_config" {
  type = list(object({
    cluster_identifier                  = string
    iam_roles                           = optional(list(string))
    create_built_in_roles               = optional(bool, false)
    iam_database_authentication_enabled = optional(bool, false)
  }))
  default = null
}

variable "cluster_security_groups_config" {
  type = list(object({
    cluster_identifier                          = string
    additional_security_group_ids               = optional(list(string))
    allow_traffic_from_these_security_group_ids = optional(list(string))
    allow_traffic_from_CIDR_blocks              = optional(list(string))
    allow_all_outbound_traffic                  = optional(bool, false)
  }))
  default = null
}


variable "cluster_network_config" {
  type = list(object({
    cluster_identifier     = string
    network_type           = optional(string)
    vpc_security_group_ids = optional(list(string))
  }))
  default = null
}
