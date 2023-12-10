locals {
  ff_resource_create_subnet_group = !lookup(local.cluster_subnet_group_config, "create", false) ? {} : lookup(local.cluster_subnet_group_config, "resource", {})
}

resource "aws_db_subnet_group" "subnet_group_from_vpc_id" {
  for_each    = { for k, v in local.ff_resource_create_subnet_group : k => v if lookup(v, "vpc_id", null) != null }
  name        = format("%s-%s", each.value["cluster_identifier"], "default-subnet-group")
  description = format("Subnet group for %s created from subnets from a VPC id given", each.value["cluster_identifier"])
  subnet_ids  = [for subnet_id in data.aws_subnets.fetch_subnets_by_vpc_id[each.key].ids : subnet_id]
  tags        = var.tags
}

resource "aws_db_subnet_group" "subnet_group_from_subnet_ids" {
  for_each    = { for k, v in local.ff_resource_create_subnet_group : k => v if length(lookup(v, "subnet_ids", [])) != 0 && lookup(v, "vpc_id", "") == "" }
  name        = format("%s-%s", each.value["cluster_identifier"], "default-subnet-group")
  description = format("Subnet group for %s created from explicit subnet ids", each.value["cluster_identifier"])
  subnet_ids  = each.value["subnet_ids"]
  tags        = var.tags
}
