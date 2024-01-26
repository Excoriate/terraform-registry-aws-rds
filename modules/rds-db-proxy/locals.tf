locals {
  #################################################
  # Feature flags
  #################################################
  is_enabled                                      = var.is_enabled
  is_db_proxy_enabled                             = local.is_enabled && var.db_proxy_config != null
  is_db_proxy_role_config_enabled                 = local.is_db_proxy_enabled && var.db_proxy_role_config != null
  is_db_proxy_iam_role_default_enabled            = !local.is_db_proxy_role_config_enabled
  is_db_proxy_auth_secrets_config_enabled         = !local.is_enabled ? false : var.db_proxy_auth_secrets_config != null
  is_db_proxy_timeouts_config_enabled             = !local.is_enabled ? false : var.db_proxy_timeouts_config != null
  is_db_proxy_default_target_group_config_enabled = !local.is_enabled ? false : var.db_proxy_default_target_group_config != null
  is_db_proxy_target_enabled                      = !local.is_enabled ? false : var.db_proxy_target_config != null
  is_db_proxy_networking_config_enabled           = !local.is_enabled ? false : var.db_proxy_networking_config != null
  is_db_proxy_endpoint_config_enabled             = !local.is_enabled ? false : var.db_proxy_endpoint_config != null

  #################################################
  # Enforced defaults
  #################################################
  db_proxy_debug_logging_default        = false
  db_proxy_engine_family_default        = "POSTGRESQL"
  db_proxy_idle_client_timeout_default  = 1800
  db_proxy_require_tls_default          = false
  db_proxy_timeouts_create_default      = "30m"
  db_proxy_timeouts_update_default      = "30m"
  db_proxy_timeouts_delete_default      = "30m"
  db_proxy_endpoint_target_role_default = "READ_WRITE"


  #################################################
  # Proxy
  #################################################
  db_proxy_config_normalised = !local.is_db_proxy_enabled ? [] : [
    for cfg in var.db_proxy_config : {
      name                = trimspace(cfg.name)
      debug_logging       = cfg["debug_logging"] == null ? local.db_proxy_debug_logging_default : cfg["debug_logging"]
      engine_family       = cfg["engine_family"] == null ? local.db_proxy_engine_family_default : cfg["engine_family"]
      idle_client_timeout = cfg["idle_client_timeout"] == null ? local.db_proxy_idle_client_timeout_default : cfg["idle_client_timeout"]
      require_tls         = cfg["require_tls"] == null ? local.db_proxy_require_tls_default : cfg["require_tls"]
    }
  ]

  db_proxy_config_create = !local.is_db_proxy_enabled ? {} : {
    for cfg in local.db_proxy_config_normalised : cfg["name"] => cfg
  }

  #################################################
  # Role Config
  #################################################
  db_proxy_role_config_normalised = !local.is_db_proxy_role_config_enabled ? [] : [
    for cfg in var.db_proxy_role_config : {
      name     = trimspace(cfg.name)
      role_arn = cfg["existing_role_arn"] == null ? null : trimspace(cfg["existing_role_arn"])
      attach_policies_arn = cfg["attach_policies_arn"] == null ? [] : [
        for arn in cfg["attach_policies_arn"] : trimspace(arn)
      ]
    }
  ]

  db_proxy_role_config_create = !local.is_db_proxy_role_config_enabled ? {} : {
    for cfg in local.db_proxy_role_config_normalised : cfg["name"] => cfg
  }

  #################################################
  # Auth Secrets Config
  #################################################
  db_proxy_auth_secrets_config_normalised = !local.is_db_proxy_auth_secrets_config_enabled ? [] : [
    for cfg in var.db_proxy_auth_secrets_config : {
      name        = trimspace(cfg.name)
      auth_scheme = "SECRETS"
      secret_arn  = cfg.secret_arn == null ? null : trimspace(cfg.secret_arn)
      iam_auth    = false // This line is redundant since auth_scheme is set to "SECRETS"
      description = format("Secret for RDS Proxy %s", cfg.name)
    }
  ]

  // For this particular object, this map isn't required.
  #  db_proxy_auth_secrets_config_create = !local.is_db_proxy_auth_secrets_config_enabled ? {} : {
  #    for cfg in local.db_proxy_auth_secrets_config_normalised : cfg["name"] => cfg
  #  }

  ####################################
  # Timeouts
  ####################################
  db_proxy_timeouts_config_normalised = !local.is_db_proxy_timeouts_config_enabled ? [] : [
    for cfg in var.db_proxy_timeouts_config : {
      name   = trimspace(cfg["name"])
      create = cfg["create"] == null ? local.db_proxy_timeouts_create_default : cfg["create"]
      update = cfg["update"] == null ? local.db_proxy_timeouts_update_default : cfg["update"]
      delete = cfg["delete"] == null ? local.db_proxy_timeouts_delete_default : cfg["delete"]
    }
  ]

  #  db_proxy_timeouts_config_create = !local.is_db_proxy_timeouts_config_enabled ? {} : {
  #    for cfg in local.db_proxy_timeouts_config_normalised : cfg["name"] => cfg
  #  }

  ####################################
  # Default Target Group
  ####################################
  db_proxy_default_target_group_config_normalised = !local.is_db_proxy_default_target_group_config_enabled ? [] : [
    for cfg in var.db_proxy_default_target_group_config : {
      name = trimspace(cfg["name"])
      connection_pool_config = cfg["connection_pool_config"] == null ? {} : {
        init_query                   = cfg["connection_pool_config"]["init_query"] == null ? null : trimspace(cfg["connection_pool_config"]["init_query"])
        max_connections_percent      = cfg["connection_pool_config"]["max_connections_percent"] == null ? null : trimspace(cfg["connection_pool_config"]["max_connections_percent"])
        max_idle_connections_percent = cfg["connection_pool_config"]["max_idle_connections_percent"] == null ? null : trimspace(cfg["connection_pool_config"]["max_idle_connections_percent"])
        session_pinning_filters = cfg["connection_pool_config"]["session_pinning_filters"] == null ? null : [
          for filter in cfg["connection_pool_config"]["session_pinning_filters"] : trimspace(filter)
        ]
      }
    }
  ]

  db_proxy_default_target_group_config_create = !local.is_db_proxy_default_target_group_config_enabled ? {} : {
    for cfg in local.db_proxy_default_target_group_config_normalised : cfg["name"] => cfg
  }

  ####################################
  # Target
  ####################################
  db_proxy_target_config_normalised = !local.is_db_proxy_target_enabled ? [] : [
    for cfg in var.db_proxy_target_config : {
      name                   = trimspace(cfg["name"])
      db_instance_identifier = cfg["db_instance_identifier"] == null ? null : trimspace(cfg["db_instance_identifier"])
      db_cluster_identifier  = cfg["db_cluster_identifier"] == null ? null : trimspace(cfg["db_cluster_identifier"])
    }
  ]

  db_proxy_target_config_create = !local.is_db_proxy_target_enabled ? {} : {
    for cfg in local.db_proxy_target_config_normalised : cfg["name"] => cfg
  }

  ####################################
  # Networking config
  ####################################
  db_proxy_networking_config_normalised = !local.is_db_proxy_networking_config_enabled ? [] : [
    for cfg in var.db_proxy_networking_config : {
      name = trimspace(cfg["name"])
      vpc_security_group_ids = cfg["vpc_security_group_ids"] == null ? [] : [
        for sg in cfg["vpc_security_group_ids"] : trimspace(sg)
      ]
      vpc_subnet_ids = cfg["vpc_subnet_ids"] == null ? [] : [
        for subnet in cfg["vpc_subnet_ids"] : trimspace(subnet)
      ]
    }
  ]

  db_proxy_networking_config_create = !local.is_db_proxy_networking_config_enabled ? {} : {
    for cfg in local.db_proxy_networking_config_normalised : cfg["name"] => cfg
  }

  ####################################
  # Endpoint config
  ####################################
  db_proxy_endpoint_config_normalised = !local.is_db_proxy_endpoint_config_enabled ? [] : [
    for cfg in var.db_proxy_endpoint_config : {
      name = trimspace(cfg["name"])
      vpc_subnet_ids = cfg["vpc_subnet_ids"] == null ? [] : [
        for subnet in cfg["vpc_subnet_ids"] : trimspace(subnet)
      ]
      target_role = cfg["target_role"] == null ? local.db_proxy_endpoint_target_role_default : trimspace(cfg["target_role"])
    }
  ]

  db_proxy_endpoint_config_create = !local.is_db_proxy_endpoint_config_enabled ? {} : {
    for cfg in local.db_proxy_endpoint_config_normalised : cfg["name"] => cfg
  }
}
