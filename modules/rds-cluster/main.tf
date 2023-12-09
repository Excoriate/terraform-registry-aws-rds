locals {
  ff_resource_create_cluster_primary   = !lookup(local.cluster_config, "create", false) ? {} : { for k, v in local.cluster_config["resource"] : k => v if !v["is_secondary"] }
  ff_resource_create_cluster_secondary = !lookup(local.cluster_config, "create", false) ? {} : { for k, v in local.cluster_config["resource"] : k => v if v["is_secondary"] }
  ff_resource_create                   = !lookup(local.cluster_config, "create", false) ? {} : lookup(local.cluster_config, "resource", {})

  // Additional security groups
  cfg_additional_security_group_ids = compact(flatten([join("", [for sg in aws_security_group.this : sg.id]), lookup(local.ff_resource_create_sg, "allow_traffic_from_security_group_ids", null)]))
}

resource "random_password" "this" {
  for_each = local.ff_resource_create
  length   = 11
  special  = false
}


resource "aws_rds_cluster" "primary" {
  for_each           = local.ff_resource_create_cluster_primary
  cluster_identifier = each.value["cluster_identifier"]
  // Credentials
  database_name                   = each.value["database_name"]
  master_username                 = lookup(each.value["options"], "ignore_admin_credentials", false) ? null : each.value["master_username"]
  master_password                 = lookup(each.value["options"], "ignore_admin_credentials", false) ? null : lookup(each.value["options"], "generate_random_password", false) ? random_password.this[each.key].result : each.value["master_password"]
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]
  // Subnet group configuration
  // 1. Precedence is given to the subnet_group_name if provided, if not, it follows the vpc_id, and if not, it follows the subnet_ids.
  db_subnet_group_name = !local.is_cluster_subnet_group_config_enabled ? null : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_subgroup_name", false) ? lookup(local.cluster_subnet_group_config[each.key], "subnet_group_name", null) : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_ids", false) ? aws_db_subnet_group.subnet_group_from_subnet_ids[each.key].name : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_vpc_id", false) ? aws_db_subnet_group.subnet_group_from_vpc_id[each.key].name : null

  // IAM roles & permissions configuration
  iam_roles                           = lookup({ for k, v in local.cluster_iam_roles_config : k => v["iam_roles"] if k == each.key }, each.key, null)
  iam_database_authentication_enabled = lookup({ for k, v in local.cluster_iam_roles_config : k => v["iam_database_authentication_enabled"] if k == each.key }, each.key, null)

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

  // Security groups
  vpc_security_group_ids = local.cfg_additional_security_group_ids

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.cluster_serverless_config == null ? [] : lookup(local.cluster_serverless_config, each.key, null) == null ? [] : lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"] == null ? [] : lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v1"] != null ? [] : [lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"]]

    content {
      max_capacity = serverlessv2_scaling_configuration.value["max_capacity"]
      min_capacity = serverlessv2_scaling_configuration.value["min_capacity"]
    }
  }

  dynamic "scaling_configuration" {
    for_each = local.cluster_serverless_config == null ? [] : lookup(local.cluster_serverless_config, each.key, null) == null ? [] : lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v1"] == null ? [] : lookup(local.cluster_serverless_config, each.key)["scaling_configuration_for_v2"] != null ? [] : [lookup(local.cluster_serverless_config, each.key)["scaling_configuration"]]

    content {
      auto_pause               = scaling_configuration.value["auto_pause"]
      max_capacity             = scaling_configuration.value["max_capacity"]
      min_capacity             = scaling_configuration.value["min_capacity"]
      seconds_until_auto_pause = scaling_configuration.value["seconds_until_auto_pause"]
    }
  }

  dynamic "timeouts" {
    for_each = lookup(local.cluster_timeouts_config, each.key, null) != null ? [lookup(local.cluster_timeouts_config, each.key)] : []
    content {
      create = timeouts.value["create"]
      delete = timeouts.value["delete"]
      update = timeouts.value["update"]
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
  }

  tags = var.tags
}
