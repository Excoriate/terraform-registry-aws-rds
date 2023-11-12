locals {
  aws_region_to_deploy = var.aws_region

  /*
    * Feature flags
  */
  is_enabled = !var.is_enabled ? false : var.module_config == null ? false : length(var.module_config) > 0
  /*
    * SSM parameter store normalisation process.
  */
  parameters_cfg_normalized = !local.is_enabled ? [] : [
    for cfg in var.module_config : {
      id   = trimspace(lower(cfg.name))
      name = contains([trimspace(cfg.parameter_path)], "/") ? trimspace(cfg.parameter_path) : format("/%s", trimspace(cfg.parameter_path))
      type = trimspace(cfg.parameter_type)

      // Set of optional properties allowed
      allowed_pattern = cfg["allowed_pattern"] != null ? trimspace(cfg["allowed_pattern"]) : null
      data_type       = cfg["data_type"] != null ? trimspace(cfg["data_type"]) : null
      description     = cfg["description"] != null ? trimspace(cfg["description"]) : null
      insecure_value  = cfg["insecure_value"] != null ? trimspace(cfg["insecure_value"]) : null
      key_id          = cfg["key_id"] != null ? trimspace(cfg["key_id"]) : null
      overwrite       = cfg["overwrite"] != null ? trimspace(cfg["overwrite"]) : null
      tier            = cfg["tier"] != null ? trimspace(cfg["tier"]) : null
      value           = cfg["value"] != null ? trimspace(cfg["value"]) : null
    }
  ]

  parameters_cfg_create = !local.is_enabled ? {} : {
    for cfg in local.parameters_cfg_normalized : cfg["id"] => cfg
  }
}
