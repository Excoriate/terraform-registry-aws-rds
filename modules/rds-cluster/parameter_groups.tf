locals {
  ff_resource_create_parameter_group = !lookup(local.cluster_parameter_groups_config, "create", false) ? {} : local.cluster_parameter_groups_config["resource"]
}

resource "aws_rds_cluster_parameter_group" "this" {
  for_each    = local.ff_resource_create_parameter_group
  name        = each.value["parameter_group_name"]
  description = each.value["parameter_group_description"]
  family      = each.value["parameter_group_family"]

  dynamic "parameter" {
    for_each = each.value["parameters"]
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  tags = var.tags
}
