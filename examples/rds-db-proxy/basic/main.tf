module "main_module" {
  source     = "../../../modules/rds-db-proxy"
  is_enabled = var.is_enabled
}
