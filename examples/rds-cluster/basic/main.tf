module "main_module" {
  source                           = "../../../modules/rds-cluster"
  is_enabled                       = var.is_enabled
  cluster_config                   = var.cluster_config
  cluster_backup_config            = var.cluster_backup_config
  cluster_change_management_config = var.cluster_change_management_config
  cluster_replication_config       = var.cluster_replication_config
  cluster_storage_config           = var.cluster_storage_config
  cluster_serverless_config        = var.cluster_serverless_config
  cluster_timeouts_config          = var.cluster_timeouts_config
  cluster_iam_roles_config         = var.cluster_iam_roles_config
  cluster_security_groups_config   = var.cluster_security_groups_config
  cluster_network_config           = var.cluster_network_config
}