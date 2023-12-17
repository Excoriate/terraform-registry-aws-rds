module "main_module" {
  source                                       = "../../../modules/rds-cluster-sg"
  is_enabled                                   = var.is_enabled
  tags                                         = var.tags
  security_group_config                        = var.security_group_config
  vpc_config                                   = var.vpc_config
  security_group_ids_to_allow_inbound_traffic  = var.security_group_ids_to_allow_inbound_traffic
  security_group_ids_to_allow_outbound_traffic = var.security_group_ids_to_allow_outbound_traffic
}
