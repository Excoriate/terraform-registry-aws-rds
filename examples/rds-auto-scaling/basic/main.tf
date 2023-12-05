module "main_module" {
  source     = "../../../modules/rds-auto-scaling"
  is_enabled = var.is_enabled
}
