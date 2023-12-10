locals {
  ff_data_fetch_subnets_by_vpc_id = local.ff_resource_create_subnet_group_by_vpc_id
}

data "aws_subnets" "fetch_subnets_by_vpc_id" {
  for_each = local.ff_data_fetch_subnets_by_vpc_id
  filter {
    name   = "vpc-id"
    values = [each.value["vpc_id"]]
  }
}

locals {
  ff_data_fetch_vpc_by_vpc_id = lookup(local.ff_resource_create_sg, "vpc_id", null) == null ? {} : local.ff_resource_create_sg

  ff_data_fetch_vpc_by_vpc_name = {
    for k, v in local.ff_resource_create_sg : k => v if lookup(v, "vpc_name", null) != null
  }
}

data "aws_vpc" "vpc_from_vpc_id" {
  for_each = local.ff_data_fetch_vpc_by_vpc_id
  id       = each.value["vpc_id"]
}

data "aws_vpc" "vpc_from_vpc_name" {
  for_each = local.ff_data_fetch_vpc_by_vpc_name
  filter {
    name   = "tag:Name"
    values = [each.value["vpc_name"]]
  }
}
