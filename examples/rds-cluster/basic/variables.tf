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
#variable "aws_region" {
#  type        = string
#  default     = "us-east-1"
#  description = "AWS region to deploy to"
#}

###################################
# Specific for this module
###################################
variable "cluster_config" {
  type = object({
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
    db_cluster_instance_class       = optional(string)
    is_secondary                    = optional(bool, false)
  })
  default     = null
  description = <<EOF
  Cluster configurations to create. Each element of the list is an object that represents
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
  - db_cluster_instance_class: (Optional) The instance class to use. For details on CPU and memory, see Scaling Aurora PostgreSQL DB clusters. Defaults to db.r5.large.
  - is_secondary: (Optional) Whether this cluster is the secondary cluster of a global database cluster or not. Default is false.
EOF
}

variable "cluster_backup_config" {
  type = object({
    cluster_identifier        = string
    backup_retention_period   = optional(number, 5)
    preferred_backup_window   = optional(string, "07:00-09:00")
    skip_final_snapshot       = optional(bool, true)
    final_snapshot_identifier = optional(string)
    copy_tags_to_snapshot     = optional(bool, false)
    backtrack_window          = optional(number, 0)
    delete_automatic_backups  = optional(bool, false)
  })
  description = <<EOF
  Cluster backup configurations to create. Each element of the list is an object that represents
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
  type = object({
    cluster_identifier           = string
    apply_immediately            = optional(bool, false)
    allow_major_version_upgrade  = optional(bool, false)
    preferred_maintenance_window = optional(string, "sun:05:00-sun:07:00")
    deletion_protection          = optional(bool, false)
  })
  description = <<EOF
  Cluster change management configurations to create. This configuration encapsulates the
  changes that will be applied to the cluster. The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - apply_immediately: (Optional) Indicates whether the modifications in this request and any pending modifications are asynchronously applied as soon as possible, regardless of the PreferredMaintenance Window setting for the DB cluster. If this parameter is set to false, changes to the DB cluster are applied during the next maintenance window. The ApplyImmediately parameter only affects the NewDBClusterIdentifier and MasterUserPassword values. If you set this parameter value to false, the changes to the NewDBClusterIdentifier and MasterUserPassword values are applied during the next maintenance window. All other changes are applied immediately, regardless of the value of the ApplyImmediately parameter. Default is false.
  - allow_major_version_upgrade: (Optional) Indicates that major version upgrades are allowed. Changing this parameter doesn't result in an outage and the change is asynchronously applied as soon as possible. Constraints: This parameter must be set to true when specifying a value for the EngineVersion parameter that is a different major version than the DB cluster's current version.
  - preferred_maintenance_window: (Optional) The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC). For more information, see Amazon RDS Maintenance Window. Format: ddd:hh24:mi-ddd:hh24:mi. Valid Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun. Constraints: Minimum 30-minute window.
  - deletion_protection: (Optional) If the DB cluster is a read replica, then set this to true in order to prevent it from being deleted when it is identified by Terraform as a managed replica of another DB cluster. Defaults to false.
EOF
  default     = null
}

variable "cluster_replication_config" {
  type = object({
    cluster_identifier             = string
    replication_source_identifier  = optional(string)
    replication_source_region      = optional(string)
    enable_global_write_forwarding = optional(bool, false)
    global_cluster_identifier      = optional(string)
  })
  description = <<EOF
  Cluster configuration for replication configurations to create. This configuration encapsulates the
necessary configuration for making this cluster a 'replica' or a 'secondary' of another cluster.
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - replication_source_identifier: (Optional) The Amazon Resource Name (ARN) of the source DB instance or DB cluster if this DB cluster is created as a read replica.
  - replication_source_region: (Optional) The region of the source DB instance or DB cluster if this DB cluster is created as a read replica.
  - enable_global_write_forwarding: (Optional) Enable write forwarding for a cluster in a different region. Default is false.
  - global_cluster_identifier: (Optional) The global cluster identifier of an Aurora cluster that becomes the primary cluster in the new global database cluster. Works only
if this cluster is set to 'secondary', and the primary cluster is in a different region.
EOF
  default     = null
}

variable "cluster_storage_config" {
  type = object({
    cluster_identifier = string
    storage_encrypted  = optional(bool, false)
    storage_type       = optional(string, "gp2")
    iops               = optional(number)
    allocated_storage  = optional(number)
    kms_key_id         = optional(string)
  })
  default     = null
  description = <<EOF
  Cluster configuration for storage configurations to create. This configuration encapsulates the
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
  type = object({
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
  })
  default     = null
  description = <<EOF
  Cluster configuration for serverless configurations to create. This configuration encapsulates the
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
  type = object({
    cluster_identifier = string
    create             = optional(string, "30m")
    delete             = optional(string, "30m")
    update             = optional(string, "30m")
  })
  default     = null
  description = <<EOF
  Cluster configuration for timeouts configurations to create. This configuration encapsulates the
necessary configuration for the timeouts of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - create: (Optional) Time to wait for the cluster to be created. Defaults to 30 minutes.
  - delete: (Optional) Time to wait for the cluster to be deleted. Defaults to 30 minutes.
  - update: (Optional) Time to wait for the cluster to be updated. Defaults to 30 minutes.
EOF
}

variable "cluster_iam_roles_config" {
  type = object({
    cluster_identifier                  = string
    iam_roles                           = optional(list(string))
    iam_database_authentication_enabled = optional(bool, false)
  })
  default     = null
  description = <<EOF
  Cluster configuration for IAM roles configurations to create. This configuration encapsulates the
necessary configuration for the IAM roles of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - iam_roles: (Optional) A List of ARNs for the IAM roles to associate to the RDS Cluster.
  - iam_database_authentication_enabled: (Optional) Whether to enable mapping of AWS Identity and Access Management (IAM) accounts to database accounts. Default is false.
EOF
}

variable "cluster_subnet_group_config" {
  type = object({
    cluster_identifier = string
    subnet_ids         = optional(list(string))
    subnet_group_name  = optional(string)
    vpc_id             = optional(string)
    vpc_name           = optional(string)
  })
  default     = null
  description = <<EOF
  Cluster configuration for subnet group configurations to create. It works by either passing a list of subnet ids or a vpc id, from
  which the module will create a subnet group with all the subnets in the vpc. For more information about its validations,
  see the terraform aws_db_subnet_group resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
  The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - subnet_ids: (Optional) A list of VPC subnet IDs. If the VPC ID is provided, the module will create a subnet group with all the subnets in the VPC.
  - subnet_group_name: (Optional) The name of the DB subnet group. If omitted, Terraform will assign a random, unique name.
  - vpc_id: (Optional) The VPC ID. If the subnet_ids are provided, the module will create a subnet group with all the subnets in the VPC.
  - vpc_name: (Optional) The VPC name. If the subnet_ids are provided, the module will create a subnet group with all the subnets in the VPC.
The precedence order is: Subnet_group_name > Subnet_ids > Vpc_id
EOF
}

variable "cluster_security_groups_config" {
  type = object({
    cluster_identifier                  = string
    vpc_id                              = optional(string)
    vpc_name                            = optional(string)
    allow_traffic_from_database_members = optional(bool, false)
    allow_traffic_from_cidr_blocks      = optional(list(string))
    allow_all_outbound_traffic          = optional(bool, false)
    allow_all_inbound_traffic           = optional(bool, false)
    db_port                             = number
  })
  default     = null
  description = <<EOF
  Cluster configuration for security group configurations to create. This configuration encapsulates the
necessary configuration for the security groups of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - vpc_id: (Optional) The VPC ID. If the vpc_name is provided, the module will use the vpc_id of the vpc_name.
  - vpc_name: (Optional) The VPC name. If the vpc_id is provided, the module will use the vpc_id.
  - allow_traffic_from_database_members: (Optional) Whether to allow traffic from the database members or not. Default is false.
  - allow_traffic_from_CIDR_blocks: (Optional) A list of CIDR blocks to allow traffic from.
  - allow_all_outbound_traffic: (Optional) Whether to allow all outbound traffic or not. Default is false.
  - allow_all_inbound_traffic: (Optional) Whether to allow all inbound traffic or not. Default is false. Not recommended.
For more information about how security groups works in the context of RDS, and Aurora specifically, see the AWS documentation in: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.html
  - db_port: The port on which the DB accepts connections. Default is 5432.
EOF
}

variable "cluster_security_groups_allowed_config" {
  type = list(object({
    cluster_identifier = string
    security_group_id  = string
    db_port            = number
    vpc_id             = optional(string)
    vpc_name           = optional(string)
  }))
  default     = null
  description = <<EOF
  Cluster configuration for security group configurations to create. This configuration encapsulates the
necessary configuration for the security groups of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - security_group_id: (Optional) A list of additional security group IDs to allow access to from the cluster. These sg's should be in the same VPC. Default is [].
  - db_port: The port on which the DB accepts connections. Default is 5432.
  - vpc_id: (Optional) The VPC ID. If the vpc_name is provided, the module will use the vpc_id of the vpc_name.
  - vpc_name: (Optional) The VPC name. If the vpc_id is provided, the module will use the vpc_id.
EOF
}

variable "cluster_restore_to_point_in_time_config" {
  type = object({
    cluster_identifier         = string
    source_cluster_identifier  = optional(string, "120m")
    restore_type               = optional(string, "copy-on-write")
    use_latest_restorable_time = optional(bool, true)
  })
  default     = null
  description = <<EOF
  Cluster configuration for restore to point in time configurations to create. This configuration encapsulates the
necessary configuration for the restore to point in time of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - source_cluster_identifier: (Optional) The identifier of the source cluster from which to restore.
  - restore_type: (Optional) The type of restore to be performed. Valid values are copy-on-write, which creates a new cluster from a snapshot and then restores data into it, and point-in-time, which restores data from an existing cluster into a new cluster based on the specified time. Default is copy-on-write.
  - use_latest_restorable_time: (Optional) Specifies whether (true) or not (false) the DB cluster is restored from the latest backup time. Default is true.
EOF
}


variable "cluster_network_config" {
  type = object({
    cluster_identifier            = string
    network_type                  = optional(string, "IPV4")
    additional_security_group_ids = optional(list(string), [])
  })
  default     = null
  description = <<EOF
  Cluster configuration for network configurations to create. This configuration encapsulates the
necessary configuration for the network of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - network_type: (Optional) The type of network to create. Valid values are IPV4, and DUAL. Default is IPV4.
  - additional_security_group_ids: (Optional) A list of additional security group IDs to allow access to from the cluster. These sg's should be in the same VPC. Default is [].
EOF
}

variable "cluster_parameter_groups_config" {
  type = object({
    cluster_identifier     = string
    parameter_group_name   = optional(string)
    parameter_group_family = optional(string, "aurora.5.6")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "pending-reboot")
    })))
  })
  default     = null
  description = <<EOF
  Cluster configuration for parameter groups configurations to create. This configuration encapsulates the
necessary configuration for the parameter groups of the cluster. For more information about its validations,
see the terraform aws_rds_cluster resource documentation in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
The supported attributes are:
  - cluster_identifier: (Required) The cluster identifier.
  - parameter_group_name: (Optional) The name of the DB parameter group to associate with this DB cluster.
  - parameter_group_family: (Optional) The family of the DB parameter group.
  - parameters: (Optional) A list of DB parameters to apply.
  - parameters.name: (Required) The name of the DB parameter.
  - parameters.value: (Required) The value of the DB parameter.
  - parameters.apply_method: (Optional) Indicates when to apply parameter updates. Can be immediate or pending-reboot. Default is pending-reboot.
EOF
}
