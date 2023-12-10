locals {
  #################################################
  # Conditional resource creation pattern
  #################################################
  default_no_create = {
    create   = false
    resource = {}
  }

  default_create = {
    create   = true
    resource = {}
  }


  #################################################
  # Feature flags
  #################################################
  is_enabled                                         = var.is_enabled
  is_cluster_enabled                                 = !local.is_enabled ? false : var.cluster_config != null
  is_cluster_backup_config_enabled                   = !local.is_cluster_enabled ? false : var.cluster_backup_config != null
  is_cluster_change_management_config_enabled        = !local.is_cluster_enabled ? false : var.cluster_change_management_config != null
  is_cluster_replication_config_enabled              = !local.is_cluster_enabled ? false : var.cluster_replication_config != null
  is_cluster_storage_config_enabled                  = !local.is_cluster_enabled ? false : var.cluster_storage_config != null
  is_cluster_serverless_config_enabled               = !local.is_cluster_enabled ? false : var.cluster_serverless_config != null
  is_cluster_timeouts_config_enabled                 = !local.is_cluster_enabled ? false : var.cluster_timeouts_config != null
  is_cluster_iam_roles_config_enabled                = !local.is_cluster_enabled ? false : var.cluster_iam_roles_config != null
  is_cluster_subnet_group_config_enabled             = !local.is_cluster_enabled ? false : var.cluster_subnet_group_config != null
  is_cluster_security_groups_config_enabled          = !local.is_cluster_enabled ? false : var.cluster_security_groups_config != null
  is_cluster_restore_to_point_in_time_config_enabled = !local.is_cluster_enabled ? false : var.cluster_restore_to_point_in_time_config != null
  is_cluster_network_config_enabled                  = !local.is_cluster_enabled ? false : var.cluster_network_config != null
  is_cluster_parameter_groups_config_enabled         = !local.is_cluster_enabled ? false : var.cluster_parameter_groups_config != null
  is_cluster_security_groups_allowed_config_enabled  = !local.is_cluster_enabled ? false : var.cluster_security_groups_allowed_config != null

  #################################################
  # Cluster config
  #################################################
  cluster_config_normalised = !local.is_cluster_enabled ? [] : [
    {
      cluster_identifier          = trimspace(var.cluster_config.cluster_identifier)
      database_name               = var.cluster_config.database_name == null ? null : trimspace(var.cluster_config.database_name)
      master_username             = var.cluster_config.is_secondary || var.cluster_config.snapshot_identifier != null ? null : var.cluster_config.master_username == null ? "goduser" : trimspace(var.cluster_config.master_username)
      manage_master_user_password = var.cluster_config.is_secondary
      master_password             = var.cluster_config.is_secondary || var.cluster_config.snapshot_identifier != null ? null : var.cluster_config.master_password == null ? null : trimspace(var.cluster_config.master_password)
      engine                      = var.cluster_config.engine == null ? "aurora-postgresql" : trimspace(var.cluster_config.engine)
      engine_mode                 = var.cluster_config.engine_mode == null ? "provisioned" : trimspace(var.cluster_config.engine_mode)
      engine_version              = var.cluster_config.engine_version == null ? null : trimspace(var.cluster_config.engine_version)
      snapshot_identifier         = var.cluster_config.snapshot_identifier == null ? null : trimspace(var.cluster_config.snapshot_identifier)
      enabled_cloudwatch_logs_exports = var.cluster_config.enabled_cloudwatch_logs_exports == null ? [] : [
        for log in var.cluster_config.enabled_cloudwatch_logs_exports : trimspace(log)
      ]
      is_secondary = var.cluster_config.is_secondary == null ? false : var.cluster_config.is_secondary
    }
  ]

  cluster_config = !local.is_cluster_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_config_normalised : cluster["cluster_identifier"] => cluster
    }
  }) // Add the 'create' flag to the resource

  #################################################
  # Cluster backup config
  #################################################
  cluster_backup_normalised = !local.is_cluster_backup_config_enabled ? [] : [
    {
      cluster_identifier        = trimspace(var.cluster_backup_config.cluster_identifier)
      backup_retention_period   = var.cluster_backup_config.backup_retention_period == null ? 5 : var.cluster_backup_config.backup_retention_period
      preferred_backup_window   = var.cluster_backup_config.preferred_backup_window == null ? "00:00-00:00" : trimspace(var.cluster_backup_config.preferred_backup_window)
      skip_final_snapshot       = var.cluster_backup_config.skip_final_snapshot == null ? true : var.cluster_backup_config.skip_final_snapshot
      final_snapshot_identifier = var.cluster_backup_config.final_snapshot_identifier == null ? format("%s-final-snapshot", var.cluster_config.cluster_identifier) : trimspace(var.cluster_backup_config.final_snapshot_identifier)
      copy_tags_to_snapshot     = var.cluster_backup_config.copy_tags_to_snapshot == null ? false : var.cluster_backup_config.copy_tags_to_snapshot
      backtrack_window          = var.cluster_backup_config.backtrack_window == null ? 0 : var.cluster_backup_config.backtrack_window
      delete_automatic_backups  = var.cluster_backup_config.delete_automatic_backups == null ? false : var.cluster_backup_config.delete_automatic_backups
    }
  ]

  cluster_backup_config = !local.is_cluster_backup_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_backup_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster change management config
  #################################################
  cluster_change_management_normalised = !local.is_cluster_change_management_config_enabled ? [] : [
    {
      cluster_identifier           = var.cluster_change_management_config.cluster_identifier
      apply_immediately            = var.cluster_change_management_config.apply_immediately == null ? false : var.cluster_change_management_config.apply_immediately
      allow_major_version_upgrade  = var.cluster_change_management_config.allow_major_version_upgrade == null ? false : var.cluster_change_management_config.allow_major_version_upgrade
      preferred_maintenance_window = var.cluster_change_management_config.preferred_maintenance_window == null ? null : trimspace(var.cluster_change_management_config.preferred_maintenance_window)
      deletion_protection          = var.cluster_change_management_config.deletion_protection == null ? false : var.cluster_change_management_config.deletion_protection
    }
  ]

  cluster_change_management_config = !local.is_cluster_change_management_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_change_management_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster replication configuration
  #################################################
  cluster_replication_config_normalized = !local.is_cluster_replication_config_enabled ? [] : [
    {
      cluster_identifier              = trimspace(var.cluster_replication_config.cluster_identifier)
      replication_source_identifier   = var.cluster_replication_config.replication_source_identifier == null ? null : trimspace(var.cluster_replication_config.replication_source_identifier)
      replication_source_region       = var.cluster_replication_config.replication_source_region == null ? null : trimspace(var.cluster_replication_config.replication_source_region)
      enable_cluster_write_forwarding = var.cluster_replication_config.enable_cluster_write_forwarding == null ? false : var.cluster_replication_config.enable_cluster_write_forwarding
      global_cluster_identifier       = var.cluster_replication_config.global_cluster_identifier == null ? null : trimspace(var.cluster_replication_config.global_cluster_identifier)
    }
  ]

  cluster_replication_config = !local.is_cluster_replication_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_replication_config_normalized : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster storage config
  #################################################
  cluster_storage_config_normalised = !local.is_cluster_storage_config_enabled ? [] : [
    {
      cluster_identifier = trimspace(var.cluster_storage_config.cluster_identifier)
      storage_encrypted  = var.cluster_storage_config.storage_encrypted == null ? false : var.cluster_storage_config.storage_encrypted
      kms_key_id         = var.cluster_storage_config.kms_key_id == null ? null : trimspace(var.cluster_storage_config.kms_key_id)
      storage_type       = var.cluster_storage_config.storage_type == null ? "gp2" : trimspace(var.cluster_storage_config.storage_type)
      iops               = var.cluster_storage_config.iops == null ? null : var.cluster_storage_config.iops
      allocated_storage  = var.cluster_storage_config.allocated_storage == null ? null : var.cluster_storage_config.allocated_storage
    }
  ]

  cluster_storage_config = !local.is_cluster_storage_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_storage_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster serverless configuration
  #################################################
  cluster_serverless_config_normalised = !local.is_cluster_serverless_config_enabled ? [] : [
    {
      cluster_identifier   = trimspace(var.cluster_serverless_config.cluster_identifier)
      enable_http_endpoint = var.cluster_serverless_config.enable_http_endpoint == null ? false : var.cluster_serverless_config.enable_http_endpoint
      // For v2
      scaling_configuration_for_v2 = var.cluster_serverless_config.scaling_configuration_for_v2 == null ? null : {
        max_capacity = var.cluster_serverless_config.scaling_configuration_for_v2.max_capacity == null ? 2 : var.cluster_serverless_config.scaling_configuration_for_v2.max_capacity
        min_capacity = var.cluster_serverless_config.scaling_configuration_for_v2.min_capacity == null ? 2 : var.cluster_serverless_config.scaling_configuration_for_v2.min_capacity
      }
      // For v1
      scaling_configuration_for_v1 = var.cluster_serverless_config.scaling_configuration_for_v1 == null ? null : {
        auto_pause               = var.cluster_serverless_config.scaling_configuration_for_v1.auto_pause == null ? true : var.cluster_serverless_config.scaling_configuration_for_v1.auto_pause
        max_capacity             = var.cluster_serverless_config.scaling_configuration_for_v1.max_capacity == null ? 2 : var.cluster_serverless_config.scaling_configuration_for_v1.max_capacity
        min_capacity             = var.cluster_serverless_config.scaling_configuration_for_v1.min_capacity == null ? 2 : var.cluster_serverless_config.scaling_configuration_for_v1.min_capacity
        seconds_until_auto_pause = var.cluster_serverless_config.scaling_configuration_for_v1.seconds_until_auto_pause == null ? 300 : var.cluster_serverless_config.scaling_configuration_for_v1.seconds_until_auto_pause
        timeout_action           = var.cluster_serverless_config.scaling_configuration_for_v1.timeout_action == null ? "ForceApplyCapacityChange" : var.cluster_serverless_config.scaling_configuration_for_v1.timeout_action
      }
    }
  ]


  cluster_serverless_config = !local.is_cluster_serverless_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_serverless_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster timeouts configuration
  #################################################
  cluster_timeouts_config_normalised = !local.is_cluster_timeouts_config_enabled ? [] : [
    {
      cluster_identifier = trimspace(var.cluster_timeouts_config.cluster_identifier)
      create             = var.cluster_timeouts_config.create == null ? "30m" : var.cluster_timeouts_config.create
      update             = var.cluster_timeouts_config.update == null ? "30m" : var.cluster_timeouts_config.update
      delete             = var.cluster_timeouts_config.delete == null ? "30m" : var.cluster_timeouts_config.delete
    }
  ]

  cluster_timeouts_config = !local.is_cluster_timeouts_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_timeouts_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster IAM roles configuration
  #################################################
  cluster_iam_roles_config_normalised = !local.is_cluster_iam_roles_config_enabled ? [] : [
    {
      cluster_identifier = trimspace(var.cluster_iam_roles_config.cluster_identifier)
      iam_roles = var.cluster_iam_roles_config.iam_roles == null ? [] : [
        for role in var.cluster_iam_roles_config.iam_roles : {
          role_name = trimspace(role["role_name"])
          status    = role["status"] == null ? "active" : trimspace(role["status"])
        }
      ]
      iam_database_authentication_enabled = var.cluster_iam_roles_config.iam_database_authentication_enabled == null ? false : var.cluster_iam_roles_config.iam_database_authentication_enabled
    }
  ]

  cluster_iam_roles_config = !local.is_cluster_iam_roles_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_iam_roles_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster Subnet Group configuration
  #################################################
  cluster_subnet_group_config_normalised = !local.is_cluster_subnet_group_config_enabled ? [] : [
    {
      cluster_identifier = trimspace(var.cluster_subnet_group_config.cluster_identifier)
      subnet_ids = var.cluster_subnet_group_config.subnet_ids == null ? [] : [
        for subnet in var.cluster_subnet_group_config.subnet_ids : trimspace(subnet)
      ]
      vpc_id            = var.cluster_subnet_group_config.vpc_id == null ? null : trimspace(var.cluster_subnet_group_config.vpc_id)
      subnet_group_name = var.cluster_subnet_group_config.subnet_group_name == null ? null : trimspace(var.cluster_subnet_group_config.subnet_group_name)
    }
  ]

  cluster_subnet_group_config = !local.is_cluster_subnet_group_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_subnet_group_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster security groups configuration
  #################################################
  cluster_security_groups_config_normalised = !local.is_cluster_security_groups_config_enabled ? [] : [
    {
      cluster_identifier                  = trimspace(var.cluster_security_groups_config.cluster_identifier)
      vpc_id                              = var.cluster_security_groups_config.vpc_id == null ? null : trimspace(var.cluster_security_groups_config.vpc_id)
      vpc_name                            = var.cluster_security_groups_config.vpc_name == null ? null : trimspace(var.cluster_security_groups_config.vpc_name)
      db_port                             = var.cluster_security_groups_config.db_port == null ? 5432 : var.cluster_security_groups_config.db_port
      allow_traffic_from_database_members = var.cluster_security_groups_config.allow_traffic_from_database_members == null ? false : var.cluster_security_groups_config.allow_traffic_from_database_members
      allow_traffic_from_cidr_blocks = var.cluster_security_groups_config.allow_traffic_from_cidr_blocks == null ? [] : [
        for cidr in var.cluster_security_groups_config.allow_traffic_from_cidr_blocks : trimspace(cidr)
      ]
      allow_all_outbound_traffic = var.cluster_security_groups_config.allow_all_outbound_traffic == null ? false : var.cluster_security_groups_config.allow_all_outbound_traffic
      allow_all_inbound_traffic  = var.cluster_security_groups_config.allow_all_inbound_traffic == null ? false : var.cluster_security_groups_config.allow_all_inbound_traffic
    }
  ]

  cluster_security_groups_config = !local.is_cluster_security_groups_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_security_groups_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster restore to point in time configuration
  #################################################
  cluster_restore_to_point_in_time_config_normalised = !local.is_cluster_restore_to_point_in_time_config_enabled ? [] : [
    {
      cluster_identifier         = trimspace(var.cluster_restore_to_point_in_time_config.cluster_identifier)
      source_cluster_identifier  = var.cluster_restore_to_point_in_time_config.source_cluster_identifier == "120m" ? null : trimspace(var.cluster_restore_to_point_in_time_config.source_cluster_identifier)
      use_latest_restorable_time = var.cluster_restore_to_point_in_time_config.use_latest_restorable_time == null ? true : var.cluster_restore_to_point_in_time_config.use_latest_restorable_time
      restore_type               = var.cluster_restore_to_point_in_time_config.restore_type == null ? "copy-on-write" : trimspace(var.cluster_restore_to_point_in_time_config.restore_type)
    }
  ]

  cluster_restore_to_point_in_time_config = !local.is_cluster_restore_to_point_in_time_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_restore_to_point_in_time_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster network configuration
  #################################################
  cluster_network_config_normalised = !local.is_cluster_network_config_enabled ? [] : [
    {
      cluster_identifier = trimspace(var.cluster_network_config.cluster_identifier)
      network_type       = var.cluster_network_config.network_type == null ? "IPv4" : trimspace(var.cluster_network_config.network_type)
      additional_security_group_ids = var.cluster_network_config.additional_security_group_ids == null ? [] : [
        for sg in var.cluster_network_config.additional_security_group_ids : trimspace(sg)
      ]
    }
  ]

  cluster_network_config = !local.is_cluster_network_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_network_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Cluster parameter groups configuration
  #################################################
  cluster_parameter_groups_config_normalised = !local.is_cluster_parameter_groups_config_enabled ? [] : [
    {
      cluster_identifier          = trimspace(var.cluster_parameter_groups_config.cluster_identifier)
      parameter_group_name        = var.cluster_parameter_groups_config.parameter_group_name == null ? format("cluster-%s-param-group", var.cluster_parameter_groups_config.cluster_identifier) : trimspace(var.cluster_parameter_groups_config.parameter_group_name)
      parameter_group_description = format("Parameter group for cluster %s", var.cluster_parameter_groups_config.cluster_identifier)
      parameter_group_family      = var.cluster_parameter_groups_config.parameter_group_family == null ? "aurora.5.6" : trimspace(var.cluster_parameter_groups_config.parameter_group_family)
      parameters = var.cluster_parameter_groups_config.parameter == null ? [] : [
        for param in var.cluster_parameter_groups_config.parameter : {
          name         = trimspace(param["name"])
          value        = trimspace(param["value"])
          apply_method = param["apply_method"] == null ? "pending-reboot" : trimspace(param["apply_method"])
        }
      ]
    }
  ]

  cluster_parameter_groups_config = !local.is_cluster_parameter_groups_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_parameter_groups_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })

  #################################################
  # Security groups (additional)
  #################################################
  cluster_security_groups_allowed_config_normalised = !local.is_cluster_security_groups_allowed_config_enabled ? [] : [
    for cluster in var.cluster_security_groups_allowed_config : {
      cluster_identifier = trimspace(cluster["cluster_identifier"])
      security_group_id = cluster["security_group_id"] == null ? [] : [
        for sg in cluster["security_group_id"] : trimspace(sg)
      ]
      vpc_name = cluster["vpc_name"] == null ? null : trimspace(cluster["vpc_name"])
      vpc_id   = cluster["vpc_id"] == null ? null : trimspace(cluster["vpc_id"])
      db_port  = cluster["db_port"] == null ? 5432 : cluster["db_port"]
  }]

  cluster_security_groups_allowed_config = !local.is_cluster_security_groups_allowed_config_enabled ? local.default_no_create : merge(local.default_create, {
    resource = {
      for cluster in local.cluster_security_groups_allowed_config_normalised : cluster["cluster_identifier"] => cluster
    }
  })
}
