locals {
  #################################################
  # Feature flags
  #################################################
  is_enabled                                  = var.is_enabled
  is_cluster_enabled                          = !local.is_enabled ? false : var.cluster_config == null ? false : length(var.cluster_config) > 0
  is_cluster_backup_config_enabled            = !local.is_cluster_enabled ? false : var.cluster_backup_config == null ? false : length(var.cluster_backup_config) > 0
  is_cluster_change_management_config_enabled = !local.is_cluster_enabled ? false : var.cluster_change_management_config == null ? false : length(var.cluster_change_management_config) > 0
  is_cluster_replication_config_enabled       = !local.is_cluster_enabled ? false : var.cluster_replication_config == null ? false : length(var.cluster_replication_config) > 0
  is_cluster_storage_config_enabled           = !local.is_cluster_enabled ? false : var.cluster_storage_config == null ? false : length(var.cluster_storage_config) > 0
  is_cluster_serverless_config_enabled        = !local.is_cluster_enabled ? false : var.cluster_serverless_config == null ? false : length(var.cluster_serverless_config) > 0
  is_cluster_timeouts_config_enabled          = !local.is_cluster_enabled ? false : var.cluster_timeouts_config == null ? false : length(var.cluster_timeouts_config) > 0

  #################################################
  # Cluster config
  #################################################
  cluster_config_normalised = !local.is_cluster_enabled ? [] : [
    for cluster in var.cluster_config : {
      cluster_identifier  = trimspace(cluster["cluster_identifier"])
      database_name       = cluster["database_name"] != null ? trimspace(cluster["database_name"]) : null
      master_username     = trimspace(cluster["master_username"])
      master_password     = cluster["master_password"] != null ? trimspace(cluster["master_password"]) : null
      engine              = cluster["engine"] == null ? "aurora-postgresql" : trimspace(cluster["engine"])
      engine_mode         = cluster["engine_mode"] == null ? "provisioned" : trimspace(cluster["engine_mode"])
      engine_version      = cluster["engine_version"] == null ? null : trimspace(cluster["engine_version"])
      snapshot_identifier = cluster["snapshot_identifier"] == null ? null : trimspace(cluster["snapshot_identifier"])
      enabled_cloudwatch_logs_exports = cluster["enabled_cloudwatch_logs_exports"] == null ? [] : [
        for log in cluster["enabled_cloudwatch_logs_exports"] : trimspace(log)
      ]
      // Set of options to manage a cluster configuration
      options = {
        generate_random_password = cluster["master_password"] == null
        ignore_admin_credentials = cluster["replication_source_identifier"] != null || cluster["snapshot_identifier"] != null
      }
    }
  ]

  cluster_config = !local.is_cluster_enabled ? {} : {
    for cluster in local.cluster_config_normalised : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster backup config
  #################################################
  cluster_backup_normalised = !local.is_cluster_backup_config_enabled ? [] : [
    for cluster in var.cluster_backup_config : {
      cluster_identifier        = trimspace(cluster["cluster_identifier"])
      backup_retention_period   = cluster["backup_retention_period"] == null ? 5 : cluster["backup_retention_period"]
      preferred_backup_window   = cluster["preferred_backup_window"] == null ? "07:00-09:00" : trimspace(cluster["preferred_backup_window"])
      skip_final_snapshot       = cluster["skip_final_snapshot"] == null ? true : cluster["skip_final_snapshot"]
      final_snapshot_identifier = cluster["final_snapshot_identifier"] == null ? format("%s-final-snapshot", cluster["cluster_identifier"]) : trimspace(cluster["final_snapshot_identifier"])
      copy_tags_to_snapshot     = cluster["copy_tags_to_snapshot"] == null ? false : cluster["copy_tags_to_snapshot"]
      backtrack_window          = cluster["backtrack_window"] == null ? 0 : cluster["backtrack_window"]
      delete_automatic_backups  = cluster["delete_automatic_backups"] == null ? false : cluster["delete_automatic_backups"]
    }
  ]

  cluster_backup_config = !local.is_cluster_backup_config_enabled ? {} : {
    for cluster in local.cluster_backup_normalised : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster change management config
  #################################################
  cluster_change_management_normalised = !local.is_cluster_change_management_config_enabled ? [] : [
    for cluster in var.cluster_change_management_config : {
      cluster_identifier          = trimspace(cluster["cluster_identifier"])
      apply_immediately           = cluster["apply_immediately"] == null ? false : cluster["apply_immediately"]
      allow_major_version_upgrade = cluster["allow_major_version_upgrade"] == null ? false : cluster["allow_major_version_upgrade"]
      maintenance_window          = cluster["maintenance_window"] == null ? "sun:05:00-sun:07:00" : trimspace(cluster["maintenance_window"])
      deletion_protection         = cluster["deletion_protection"] == null ? false : cluster["deletion_protection"]
    }
  ]

  cluster_change_management_config = !local.is_cluster_change_management_config_enabled ? {} : {
    for cluster in local.cluster_change_management_normalised : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster replication configuration
  #################################################
  cluster_replication_config_normalized = !local.is_cluster_replication_config_enabled ? [] : [
    for cluster in var.cluster_replication_config : {
      cluster_identifier              = trimspace(cluster["cluster_identifier"])
      replication_source_identifier   = cluster["replication_source_identifier"] == null ? null : trimspace(cluster["replication_source_identifier"])
      replication_source_region       = cluster["replication_source_region"] == null ? null : trimspace(cluster["replication_source_region"])
      enable_cluster_write_forwarding = cluster["enable_cluster_write_forwarding"] == null ? false : cluster["enable_cluster_write_forwarding"]
    }
  ]

  cluster_replication_config = !local.is_cluster_replication_config_enabled ? {} : {
    for cluster in local.cluster_replication_config_normalized : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster storage config
  #################################################
  cluster_storage_config_normalised = !local.is_cluster_storage_config_enabled ? [] : [
    for cluster in var.cluster_storage_config : {
      cluster_identifier = trimspace(cluster["cluster_identifier"])
      storage_encrypted  = cluster["storage_encrypted"] == null ? false : cluster["storage_encrypted"]
      kms_key_id         = cluster["kms_key_id"] == null ? null : trimspace(cluster["kms_key_id"])
      storage_type       = cluster["storage_type"] == null ? "gp2" : trimspace(cluster["storage_type"])
      iops               = cluster["iops"] == null ? null : cluster["iops"]
      allocated_storage  = cluster["allocated_storage"] == null ? null : cluster["allocated_storage"]
    }
  ]

  cluster_storage_config = !local.is_cluster_storage_config_enabled ? {} : {
    for cluster in local.cluster_storage_config_normalised : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster serverless configuration
  #################################################
  cluster_serverless_config_normalised = !local.is_cluster_serverless_config_enabled ? [] : [
    for cluster in var.cluster_serverless_config : {
      cluster_identifier   = trimspace(cluster["cluster_identifier"])
      enable_http_endpoint = cluster["enable_http_endpoint"] == null ? false : cluster["enable_http_endpoint"]
      // For v2
      scaling_configuration_for_v2 = cluster["scaling_configuration_for_v2"] == null ? {} : {
        max_capacity = cluster["scaling_configuration_for_v2"]["max_capacity"] == null ? 2 : cluster["scaling_configuration_for_v2"]["max_capacity"]
        min_capacity = cluster["scaling_configuration_for_v2"]["min_capacity"] == null ? 2 : cluster["scaling_configuration_for_v2"]["min_capacity"]
      }
      // For v1
      scaling_configuration_for_v1 = cluster["scaling_configuration_for_v1"] == null ? {} : {
        auto_pause               = cluster["scaling_configuration_for_v1"]["auto_pause"] == null ? true : cluster["scaling_configuration_for_v1"]["auto_pause"]
        max_capacity             = cluster["scaling_configuration_for_v1"]["max_capacity"] == null ? 2 : cluster["scaling_configuration_for_v1"]["max_capacity"]
        min_capacity             = cluster["scaling_configuration_for_v1"]["min_capacity"] == null ? 2 : cluster["scaling_configuration_for_v1"]["min_capacity"]
        seconds_until_auto_pause = cluster["scaling_configuration_for_v1"]["seconds_until_auto_pause"] == null ? 300 : cluster["scaling_configuration_for_v1"]["seconds_until_auto_pause"]
        timeout_action           = cluster["scaling_configuration_for_v1"]["timeout_action"] == null ? "ForceApplyCapacityChange" : cluster["scaling_configuration_for_v1"]["timeout_action"]
      }
    }
  ]

  cluster_serverless_config = !local.is_cluster_serverless_config_enabled ? {} : {
    for cluster in local.cluster_serverless_config_normalised : cluster["cluster_identifier"] => cluster
  }

  #################################################
  # Cluster timeouts configuration
  #################################################


}
