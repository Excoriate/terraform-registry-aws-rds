locals {
  #################################################
  # Conditional resource creation pattern
  #################################################
  is_enabled                             = !var.is_enabled ? false : var.security_group_config != null
  is_security_group_ids_inbound_enabled  = !local.is_enabled ? false : var.security_group_ids_to_allow_inbound_traffic == null ? false : length(var.security_group_ids_to_allow_inbound_traffic) > 0
  is_security_group_ids_outbound_enabled = !local.is_enabled ? false : var.security_group_ids_to_allow_outbound_traffic == null ? false : length(var.security_group_ids_to_allow_outbound_traffic) > 0


  #################################################
  # Security group configuration
  #################################################
  sg_config_normalised = !local.is_enabled ? [] : [
    {
      name               = trimspace(lower(replace(var.security_group_config.name, " ", "-")))
      db_port            = var.security_group_config.db_port == null ? null : var.security_group_config.db_port
      description        = format("%s security group", var.security_group_config.name)
      enable_inbound_all = var.security_group_config.enable_inbound_all == null ? false : var.security_group_config.enable_inbound_all
      enable_inbound_cidr_blocks = var.security_group_config.enable_inbound_cidr_blocks == null ? [] : [
        for cidr_block in var.security_group_config.enable_inbound_cidr_blocks : cidr_block
      ]
      enable_outbound_all                     = var.security_group_config.enable_outbound_all == null ? false : var.security_group_config.enable_outbound_all
      enable_traffic_between_database_members = var.security_group_config.enable_traffic_between_database_members == null ? false : var.security_group_config.enable_traffic_between_database_members
    }
  ]

  sg_config_create = !local.is_enabled ? {} : {
    for rule in local.sg_config_normalised : rule["name"] => rule
  }

  vpc_config_normalised = !local.is_enabled ? [] : [
    {
      name     = trimspace(lower(replace(var.vpc_config.name, " ", "-")))
      vpc_id   = var.vpc_config.vpc_id == null ? null : trimspace(var.vpc_config.vpc_id)
      vpc_name = var.vpc_config.vpc_name == null ? null : trimspace(var.vpc_config.vpc_name)
    }
  ]

  #################################################
  # Vpc configuration
  #################################################
  vpc_config_create = !local.is_enabled ? {} : {
    for cfg in local.vpc_config_normalised : cfg["name"] => cfg
  }

  #################################################
  # Security group ids allowed
  #################################################
  sg_ids_inbound_normalised = !local.is_security_group_ids_inbound_enabled ? [] : [
    for sg in var.security_group_ids_to_allow_inbound_traffic : {
      name      = trimspace(lower(replace(sg["name"], " ", "-")))
      rule_name = trimspace(lower(replace(sg["rule_name"], " ", "-")))
      id        = trimspace(sg["id"])
      type      = "ingress"
      protocol  = "tcp"
    }
  ]

  sg_ids_inbound_create = !local.is_security_group_ids_inbound_enabled ? {} : {
    for sg in local.sg_ids_inbound_normalised : sg["rule_name"] => sg
  }

  sg_ids_outbound_normalised = !local.is_security_group_ids_outbound_enabled ? [] : [
    for sg in var.security_group_ids_to_allow_outbound_traffic : {
      name      = trimspace(lower(replace(sg["name"], " ", "-")))
      rule_name = trimspace(lower(replace(sg["rule_name"], " ", "-")))
      id        = trimspace(sg["id"])
      type      = "egress"
      protocol  = "tcp"
    }
  ]

  sg_ids_outbound_create = !local.is_security_group_ids_outbound_enabled ? {} : {
    for sg in local.sg_ids_outbound_normalised : sg["rule_name"] => sg
  }
}
