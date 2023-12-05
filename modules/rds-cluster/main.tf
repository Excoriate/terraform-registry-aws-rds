locals {
}

resource "random_password" "this" {
  for_each = local.cluster_config
  length   = 11
  special  = false
}

resource "aws_rds_cluster" "this" {
  for_each           = local.cluster_config
  cluster_identifier = each.value["cluster_identifier"]
  // Credentials
  database_name                   = each.value["database_name"]
  master_username                 = lookup(each.value["options"], "ignore_admin_credentials", false) ? null : each.value["master_username"]
  master_password                 = lookup(each.value["options"], "ignore_admin_credentials", false) ? null : lookup(each.value["options"], "generate_random_password", false) ? random_password.this[each.key].result : each.value["master_password"]
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]


  // Engine configuration
  engine         = each.value["engine"]
  engine_mode    = each.value["engine_mode"]
  engine_version = each.value["engine_version"]

  // Backup & restore
  backup_retention_period   = lookup({ for k, v in local.cluster_backup_config : k => v["backup_retention_period"] if k == each.key }, each.key, null)
  preferred_backup_window   = lookup({ for k, v in local.cluster_backup_config : k => v["preferred_backup_window"] if k == each.key }, each.key, null)
  skip_final_snapshot       = lookup({ for k, v in local.cluster_backup_config : k => v["skip_final_snapshot"] if k == each.key }, each.key, null)
  final_snapshot_identifier = lookup({ for k, v in local.cluster_backup_config : k => v["final_snapshot_identifier"] if k == each.key }, each.key, null)
  copy_tags_to_snapshot     = lookup({ for k, v in local.cluster_backup_config : k => v["copy_tags_to_snapshot"] if k == each.key }, each.key, null)
  backtrack_window          = lookup({ for k, v in local.cluster_backup_config : k => v["backtrack_window"] if k == each.key }, each.key, null)

  // Change management
  apply_immediately            = lookup({ for k, v in local.cluster_change_management_config : k => v["apply_immediately"] if k == each.key }, each.key, null)
  preferred_maintenance_window = lookup({ for k, v in local.cluster_change_management_config : k => v["maintenance_window"] if k == each.key }, each.key, null)
  allow_major_version_upgrade  = lookup({ for k, v in local.cluster_change_management_config : k => v["allow_major_version_upgrade"] if k == each.key }, each.key, null)
  deletion_protection          = lookup({ for k, v in local.cluster_change_management_config : k => v["deletion_protection"] if k == each.key }, each.key, null)

  // Replication configuration
  replication_source_identifier  = lookup({ for k, v in local.cluster_replication_config : k => v["replication_source_identifier"] if k == each.key }, each.key, null)
  source_region                  = lookup({ for k, v in local.cluster_replication_config : k => v["source_region"] if k == each.key }, each.key, null)
  enable_global_write_forwarding = lookup({ for k, v in local.cluster_replication_config : k => v["enable_global_write_forwarding"] if k == each.key }, each.key, null)

  // Serverless specific configuration.
  enable_http_endpoint = lookup({ for k, v in local.cluster_serverless_config : k => v["enable_http_endpoint"] if k == each.key }, each.key, null)

  dynamic "serverlessv2_scaling_configuration" {
    for_each = lookup(local.cluster_serverless_config, each.key, null) != null && lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"] != null && lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v1"] == null ? [lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"]] : []

    content {
      max_capacity = serverlessv2_scaling_configuration.value["max_capacity"]
      min_capacity = serverlessv2_scaling_configuration.value["min_capacity"]
    }
  }

  dynamic "scaling_configuration" {
    for_each = lookup(local.cluster_serverless_config, each.key, null) != null && lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v1"] != null && lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"] == null ? [lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v1"]] : []

    content {
      auto_pause               = scaling_configuration.value["auto_pause"]
      max_capacity             = scaling_configuration.value["max_capacity"]
      min_capacity             = scaling_configuration.value["min_capacity"]
      seconds_until_auto_pause = scaling_configuration.value["seconds_until_auto_pause"]
    }
  }

  lifecycle {
    precondition {
      error_message = "The engine must be one of the following: aurora, aurora-mysql, aurora-postgresql, mariadb, mysql, postgresql"
      condition     = contains(["aurora", "aurora-mysql", "aurora-postgresql", "mariadb", "mysql", "postgresql"], each.value["engine"])
    }

    precondition {
      error_message = "The master_username must not be 'admin', since it's a reserved username."
      condition     = each.value["master_username"] != "admin"
    }

    precondition {
      // If the locals.cluster_serverless_config has a key for this cluster, and the serverlessv2_scaling configuration is set, but the engine_mode is not provisioned, then fail. Why wait until the 'apply' step to fail?
      error_message = "The engine_mode must be provisioned if the var.cluster_serverless_config has a key for this cluster."
      condition     = lookup(local.cluster_serverless_config, each.key, null) == null || lookup(local.cluster_serverless_config, each.key, null)["scaling_configuration_for_v2"] == null || each.value["engine_mode"] == "provisioned"
    }

    // If the locals.cluster_serverless_config has a key for this cluster, and the serverless v1 scaling configuration is set, but the engine_mode is not serverless, then fail. Why wait until the 'apply' step to fail? it only applies if the serverless scaling configuration v2 is not set
    precondition {
      error_message = "The engine_mode must be serverless if the var.cluster_serverless_config has a key for this cluster and the scaling_config_v1 is set."
      condition     = lookup(local.cluster_serverless_config, each.key, null) == null || lookup(local.cluster_serverless_config, each.key, null)["scaling_configuration_for_v2"] != null || lookup(local.cluster_serverless_config, each.key, null)["scaling_configuration_for_v1"] == null || each.value["engine_mode"] == "serverless"
    }
  }

  tags = var.tags
}
