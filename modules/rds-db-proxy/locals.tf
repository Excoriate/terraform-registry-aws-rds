locals {
  #################################################
  # Feature flags
  #################################################
  is_enabled                           = var.is_enabled
  is_db_proxy_enabled                  = !local.is_enabled ? false : var.db_proxy_config != null
  is_db_proxy_role_config_enabled      = !local.is_enabled ? false : var.db_proxy_role_config != null
  is_db_proxy_iam_role_default_enabled = !local.is_db_proxy_role_config_enabled

  #################################################
  # Enforced defaults
  #################################################
  db_proxy_debug_logging_default       = false
  db_proxy_engine_family_default       = "POSTGRESQL"
  db_proxy_idle_client_timeout_default = 1800
  db_proxy_require_tls_default         = false


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

  db_proxy_config_create = !local.is_db_proxy_enabled ? null : {
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

  db_proxy_role_config_create = !local.is_db_proxy_role_config_enabled ? null : {
    for cfg in local.db_proxy_role_config_normalised : cfg["name"] => cfg
  }
}
