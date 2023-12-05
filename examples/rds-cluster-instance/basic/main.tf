module "main_module" {
  source     = "../../../modules/rds-cluster-instance"
  is_enabled = var.is_enabled
}
