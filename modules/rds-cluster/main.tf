locals {
  // Cluster configuration
  ff_resource_create_cluster_primary   = !lookup(local.cluster_config, "create", false) ? {} : { for k, v in local.cluster_config["resource"] : k => v if !v["is_secondary"] }
  ff_resource_create_cluster_secondary = !lookup(local.cluster_config, "create", false) ? {} : { for k, v in local.cluster_config["resource"] : k => v if v["is_secondary"] }
  ff_resource_create                   = !lookup(local.cluster_config, "create", false) ? {} : lookup(local.cluster_config, "resource", {})

  // Additional security groups
  cfg_sg_allow_traffic_from_sg_ids = compact(flatten([join("", [for sg in aws_security_group.this : sg.id]), lookup(local.ff_resource_create_sg, "allow_traffic_from_security_group_ids", null)]))

  cfg_network_additional_security_group_ids = !lookup(local.cluster_network_config, "create", false) ? {} : lookup(local.cluster_network_config, "resource", {})
}

resource "random_password" "this" {
  for_each = local.ff_resource_create
  length   = 11
  special  = false
}


resource "aws_rds_cluster" "primary" {
  for_each           = local.ff_resource_create_cluster_primary
  cluster_identifier = each.value["cluster_identifier"]
  ## ---------------------------------------------------------------------------------------------------------------------
  ## ADMIN CREDENTIALS
  ## It defines the master user credentials.
  ## ---------------------------------------------------------------------------------------------------------------------
  database_name       = each.value["database_name"]
  master_username     = each.value["master_username"]
  snapshot_identifier = each.value["snapshot_identifier"]
  #  manage_master_user_password     = false // It's the master one, so it should be ignored.
  master_password                 = each.value["master_password"] != null ? each.value["master_password"] : random_password.this[each.key].result
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SUBNET GROUP CONFIGURATION
  ## It defines the subnet group configuration. Works with a precedence order: subnet_group_name, subnet_ids, vpc_id.
  ## ---------------------------------------------------------------------------------------------------------------------
  db_subnet_group_name = !lookup(local.ff_resource_create_subnet_group, "create", false) ? null : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_subgroup_name", false) ? lookup(local.cluster_subnet_group_config[each.key], "subnet_group_name", null) : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_ids", false) ? aws_db_subnet_group.subnet_group_from_subnet_ids[each.key].name : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_vpc_id", false) ? aws_db_subnet_group.subnet_group_from_vpc_id[each.key].name : null

  ## ---------------------------------------------------------------------------------------------------------------------
  ## IAM ROLES CONFIGURATION
  ## It defines the IAM roles configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  iam_roles                           = !lookup(local.cluster_iam_roles_config, "create", false) ? [] : lookup(local.cluster_iam_roles_config, "resource", {})[each.key]["iam_roles"]
  iam_database_authentication_enabled = !lookup(local.cluster_iam_roles_config, "create", false) ? null : lookup(local.cluster_iam_roles_config, "resource", {})[each.key]["iam_database_authentication_enabled"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## CLUSTER STORAGE CONFIGURATION
  ## It defines the cluster storage configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  storage_encrypted = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["storage_encrypted"]
  kms_key_id        = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["kms_key_id"]
  storage_type      = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["storage_type"]
  iops              = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["iops"]
  allocated_storage = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["allocated_storage"]


  ## ---------------------------------------------------------------------------------------------------------------------
  ## CLUSTER ENGINE CONFIGURATION
  ## It defines the cluster engine configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  engine         = each.value["engine"]
  engine_mode    = each.value["engine_mode"]
  engine_version = each.value["engine_version"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## BACKUP & RESTORE CONFIGURATION
  ## It defines the backup & restore configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  backup_retention_period = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["backup_retention_period"]
  preferred_backup_window = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["preferred_backup_window"]
  skip_final_snapshot     = !lookup(local.cluster_backup_config, "create", false) ? true : lookup(local.cluster_backup_config, "resource", {})[each.key]["skip_final_snapshot"]

  final_snapshot_identifier = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["final_snapshot_identifier"]
  copy_tags_to_snapshot     = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["copy_tags_to_snapshot"]
  backtrack_window          = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["backtrack_window"]

  dynamic "restore_to_point_in_time" {
    for_each = !lookup(local.cluster_restore_to_point_in_time_config, "create", false) ? [] : length(lookup(local.cluster_restore_to_point_in_time_config, each.key, [])) == 0 ? [] : [lookup(local.cluster_restore_to_point_in_time_config, each.key, [])]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value["source_cluster_identifier"]
      restore_type               = restore_to_point_in_time.value["restore_type"]
      use_latest_restorable_time = restore_to_point_in_time.value["use_latest_restorable_time"]
    }
  }

  ## ---------------------------------------------------------------------------------------------------------------------
  ## CHANGE MANAGEMENT CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  apply_immediately            = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["apply_immediately"]
  preferred_maintenance_window = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["preferred_maintenance_window"]
  allow_major_version_upgrade  = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["allow_major_version_upgrade"]
  deletion_protection          = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["deletion_protection"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## REPLICATION CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  replication_source_identifier  = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["replication_source_identifier"]
  source_region                  = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["source_region"]
  enable_global_write_forwarding = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["enable_global_write_forwarding"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SERVERLESS CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  enable_http_endpoint = !lookup(local.cluster_serverless_config, "create", false) ? null : lookup(local.cluster_serverless_config, "resource", {})[each.key]["enable_http_endpoint"]

  dynamic "serverlessv2_scaling_configuration" {
    for_each = !lookup(local.cluster_serverless_config, "create", false) ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"] == null ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"] != null ? [] : [lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"]]

    content {
      max_capacity = serverlessv2_scaling_configuration.value["max_capacity"]
      min_capacity = serverlessv2_scaling_configuration.value["min_capacity"]
    }
  }

  dynamic "scaling_configuration" {
    for_each = !lookup(local.cluster_serverless_config, "create", false) ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"] == null ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"] != null ? [] : [lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"]]

    content {
      auto_pause               = scaling_configuration.value["auto_pause"]
      max_capacity             = scaling_configuration.value["max_capacity"]
      min_capacity             = scaling_configuration.value["min_capacity"]
      seconds_until_auto_pause = scaling_configuration.value["seconds_until_auto_pause"]
    }
  }

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SG & NETWORKING CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  #  vpc_security_group_ids = local.cfg_additional_security_group_ids
  vpc_security_group_ids = compact(flatten([local.cfg_sg_allow_traffic_from_sg_ids, lookup(local.cfg_network_additional_security_group_ids, each.key, [])]))
  network_type           = !lookup(local.cluster_network_config, "create", false) ? null : lookup(local.cluster_network_config, each.key, null) == null ? null : lookup(local.cluster_network_config[each.key], "network_type", null)


  dynamic "timeouts" {
    for_each = !lookup(local.cluster_timeouts_config, "create", false) ? [] : lookup(local.cluster_timeouts_config, "resource", {})[each.key]
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

  depends_on = [aws_security_group.this, aws_db_subnet_group.subnet_group_from_vpc_id, aws_db_subnet_group.subnet_group_from_subnet_ids, aws_rds_cluster_parameter_group.this]

  tags = var.tags
}

resource "aws_rds_cluster" "secondary" {
  for_each           = local.ff_resource_create_cluster_secondary
  cluster_identifier = each.value["cluster_identifier"]
  ## ---------------------------------------------------------------------------------------------------------------------
  ## ADMIN CREDENTIALS
  ## It defines the master user credentials.
  ## ---------------------------------------------------------------------------------------------------------------------
  database_name                   = each.value["database_name"]
  manage_master_user_password     = false // It's the master one, so it should be ignored.
  snapshot_identifier             = each.value["snapshot_identifier"]
  master_password                 = null
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SUBNET GROUP CONFIGURATION
  ## It defines the subnet group configuration. Works with a precedence order: subnet_group_name, subnet_ids, vpc_id.
  ## ---------------------------------------------------------------------------------------------------------------------
  db_subnet_group_name = !lookup(local.ff_resource_create_subnet_group, "create", false) ? null : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_subgroup_name", false) ? lookup(local.cluster_subnet_group_config[each.key], "subnet_group_name", null) : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_ids", false) ? aws_db_subnet_group.subnet_group_from_subnet_ids[each.key].name : lookup(local.cluster_subnet_group_config[each.key]["options"], "subnets_from_vpc_id", false) ? aws_db_subnet_group.subnet_group_from_vpc_id[each.key].name : null

  ## ---------------------------------------------------------------------------------------------------------------------
  ## IAM ROLES CONFIGURATION
  ## It defines the IAM roles configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  iam_roles                           = !lookup(local.cluster_iam_roles_config, "create", false) ? [] : lookup(local.cluster_iam_roles_config, "resource", {})[each.key]["iam_roles"]
  iam_database_authentication_enabled = !lookup(local.cluster_iam_roles_config, "create", false) ? null : lookup(local.cluster_iam_roles_config, "resource", {})[each.key]["iam_database_authentication_enabled"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## CLUSTER STORAGE CONFIGURATION
  ## It defines the cluster storage configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  storage_encrypted = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["storage_encrypted"]
  kms_key_id        = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["kms_key_id"]
  storage_type      = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["storage_type"]
  iops              = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["iops"]
  allocated_storage = !lookup(local.cluster_storage_config, "create", false) ? null : lookup(local.cluster_storage_config, "resource", {})[each.key]["allocated_storage"]


  ## ---------------------------------------------------------------------------------------------------------------------
  ## CLUSTER ENGINE CONFIGURATION
  ## It defines the cluster engine configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  engine         = each.value["engine"]
  engine_mode    = each.value["engine_mode"]
  engine_version = each.value["engine_version"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## BACKUP & RESTORE CONFIGURATION
  ## It defines the backup & restore configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  backup_retention_period = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["backup_retention_period"]
  preferred_backup_window = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["preferred_backup_window"]
  skip_final_snapshot     = !lookup(local.cluster_backup_config, "create", false) ? true : lookup(local.cluster_backup_config, "resource", {})[each.key]["skip_final_snapshot"]

  final_snapshot_identifier = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["final_snapshot_identifier"]
  copy_tags_to_snapshot     = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["copy_tags_to_snapshot"]
  backtrack_window          = !lookup(local.cluster_backup_config, "create", false) ? null : lookup(local.cluster_backup_config, "resource", {})[each.key]["backtrack_window"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## CHANGE MANAGEMENT CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  apply_immediately            = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["apply_immediately"]
  preferred_maintenance_window = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["preferred_maintenance_window"]
  allow_major_version_upgrade  = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["allow_major_version_upgrade"]
  deletion_protection          = !lookup(local.cluster_change_management_config, "create", false) ? null : lookup(local.cluster_change_management_config, "resource", {})[each.key]["deletion_protection"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## REPLICATION CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  replication_source_identifier  = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["replication_source_identifier"]
  source_region                  = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["source_region"]
  enable_global_write_forwarding = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["enable_global_write_forwarding"]
  global_cluster_identifier      = !lookup(local.cluster_replication_config, "create", false) ? null : lookup(local.cluster_replication_config, "resource", {})[each.key]["global_cluster_identifier"]

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SERVERLESS CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  enable_http_endpoint = !lookup(local.cluster_serverless_config, "create", false) ? null : lookup(local.cluster_serverless_config, "resource", {})[each.key]["enable_http_endpoint"]

  dynamic "serverlessv2_scaling_configuration" {
    for_each = !lookup(local.cluster_serverless_config, "create", false) ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"] == null ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"] != null ? [] : [lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"]]

    content {
      max_capacity = serverlessv2_scaling_configuration.value["max_capacity"]
      min_capacity = serverlessv2_scaling_configuration.value["min_capacity"]
    }
  }

  dynamic "scaling_configuration" {
    for_each = !lookup(local.cluster_serverless_config, "create", false) ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"] == null ? [] : lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v2"] != null ? [] : [lookup(local.cluster_serverless_config, "resource", {})[each.key]["scaling_configuration_for_v1"]]

    content {
      auto_pause               = scaling_configuration.value["auto_pause"]
      max_capacity             = scaling_configuration.value["max_capacity"]
      min_capacity             = scaling_configuration.value["min_capacity"]
      seconds_until_auto_pause = scaling_configuration.value["seconds_until_auto_pause"]
    }
  }

  ## ---------------------------------------------------------------------------------------------------------------------
  ## SG & NETWORKING CONFIGURATION
  ## It defines the change management configuration.
  ## ---------------------------------------------------------------------------------------------------------------------
  #  vpc_security_group_ids = local.cfg_additional_security_group_ids
  vpc_security_group_ids = compact(flatten([local.cfg_sg_allow_traffic_from_sg_ids, lookup(local.cfg_network_additional_security_group_ids, each.key, [])]))
  network_type           = !lookup(local.cluster_network_config, "create", false) ? null : lookup(local.cluster_network_config, each.key, null) == null ? null : lookup(local.cluster_network_config[each.key], "network_type", null)


  dynamic "timeouts" {
    for_each = !lookup(local.cluster_timeouts_config, "create", false) ? [] : lookup(local.cluster_timeouts_config, "resource", {})[each.key]
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

    precondition {
      error_message = "The cluster is not set to be a secondary one, but the replication configuration is set."
      condition     = !each.value["is_secondary"] && (each.value["replication_source_identifier"] != null || each.value["source_region"] != null || each.value["enable_global_write_forwarding"] != null || each.value["global_cluster_identifier"] != null)
    }

    ignore_changes = [
      replication_source_identifier, # will be set/managed by Global Cluster
      snapshot_identifier,           # if created from a snapshot, will be non-null at creation, but null afterwards
    ]
  }

  depends_on = [aws_security_group.this, aws_db_subnet_group.subnet_group_from_vpc_id, aws_db_subnet_group.subnet_group_from_subnet_ids, aws_rds_cluster_parameter_group.this]

  tags = var.tags
}

