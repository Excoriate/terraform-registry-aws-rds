resource "aws_db_subnet_group" "subnet_group_from_vpc_id" {
  for_each    = !local.is_cluster_subnet_group_config_enabled ? {} : { for cfg in local.cluster_subnet_group_config : cfg["cluster_identifier"] => cfg if lookup(cfg["options"], "subnets_from_vpc_id", null) }
  name        = format("%s-%s", each.value["cluster_identifier"], "default-subnet-group")
  description = format("Subnet group for %s", each.value["cluster_identifier"])
  subnet_ids  = [for subnet_id in data.aws_subnets.this[each.key].ids : subnet_id]
  tags        = var.tags
}
