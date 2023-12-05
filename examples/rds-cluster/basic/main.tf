module "main_module" {
  source     = "../../../modules/rds-cluster"
  is_enabled = var.is_enabled
}
