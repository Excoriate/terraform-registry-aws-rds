data "aws_subnets" "this" {
  for_each = !local.is_cluster_subnet_group_config_enabled ? {} : { for cfg in local.cluster_subnet_group_config : cfg["cluster_identifier"] => cfg if lookup(cfg["options"], "subnets_from_vpc_id", null) }
  filter {
    name   = "vpc-id"
    values = [each.value["vpc_id"]]
  }
}
