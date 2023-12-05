module "main_module" {
  source     = "../../../modules/rds-parameter-group"
  is_enabled = var.is_enabled
}
