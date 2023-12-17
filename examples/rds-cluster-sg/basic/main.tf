module "main_module" {
  source                = "../../../modules/rds-cluster-sg"
  is_enabled            = var.is_enabled
  tags                  = var.tags
  security_group_config = var.security_group_config
  vpc_config            = var.vpc_config
}
