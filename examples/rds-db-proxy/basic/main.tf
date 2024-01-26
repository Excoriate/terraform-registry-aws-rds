module "main_module" {
  source                               = "../../../modules/rds-db-proxy"
  is_enabled                           = var.is_enabled
  db_proxy_config                      = var.db_proxy_config
  db_proxy_role_config                 = var.db_proxy_role_config
  db_proxy_auth_secrets_config         = var.db_proxy_auth_secrets_config
  db_proxy_timeouts_config             = var.db_proxy_timeouts_config
  db_proxy_default_target_group_config = var.db_proxy_default_target_group_config
  db_proxy_target_config               = var.db_proxy_target_config
  db_proxy_networking_config           = var.db_proxy_networking_config
}
