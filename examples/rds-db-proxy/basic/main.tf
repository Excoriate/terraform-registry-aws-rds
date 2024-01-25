module "main_module" {
  source                       = "../../../modules/rds-db-proxy"
  is_enabled                   = var.is_enabled
  db_proxy_config              = var.db_proxy_config
  db_proxy_role_config         = var.db_proxy_role_config
  db_proxy_auth_secrets_config = var.db_proxy_auth_secrets_config
}
