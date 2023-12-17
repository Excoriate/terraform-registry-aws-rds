locals {
  ff_data_fetch_subnets_by_vpc_id = { for k, v in local.ff_resource_create_subnet_group : k => v if lookup(v, "vpc_id", null) != null }

  ff_data_fetch_vpc_by_id                 = { for k, v in local.ff_resource_create_sg : k => v if lookup(v, "vpc_id", null) != null }
  ff_data_fetch_vpc_by_name               = { for k, v in local.ff_resource_create_sg : k => v if lookup(v, "vpc_name", null) != null }
  ff_data_fetch_vpc_by_name_subnet_groups = { for k, v in local.ff_resource_create_subnet_group : k => v if lookup(v, "vpc_name", null) != null }
}

## ---------------------------------------------------------------------------------------------------------------------
## SECURITY GROUPS
## 1. If the vpc_name is passed, then it's going to fetch the VPC ID from the VPC data source
## 2. Then the VPC is obtained, it's used to fetch all the subnets from that VPC
## ---------------------------------------------------------------------------------------------------------------------
data "aws_subnets" "fetch_subnets_by_vpc_id" {
  for_each = local.ff_data_fetch_subnets_by_vpc_id
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sg_vpc_from_vpc_id[each.key].id]
  }
}

data "aws_vpc" "sg_vpc_from_vpc_id" {
  for_each = local.ff_data_fetch_vpc_by_id
  id       = each.value["vpc_id"]
}

data "aws_vpc" "sg_vpc_from_vpc_name" {
  for_each = local.ff_data_fetch_vpc_by_name
  filter {
    name   = "tag:Name"
    values = [each.value["vpc_name"]]
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## SUBNET GROUP DATA SOURCES
## 1. If the vpc_name is passed, then it's going to fetch the VPC ID from the VPC data source
## 2. Then the VPC is obtained, it's used to fetch all the subnets from that VPC
## ---------------------------------------------------------------------------------------------------------------------
data "aws_vpc" "subnet_group_fetch_vpc_by_vpc_name" {
  for_each = local.ff_data_fetch_vpc_by_name_subnet_groups
  filter {
    name   = "tag:Name"
    values = [each.value["vpc_name"]]
  }
}

data "aws_subnets" "subnet_group_fetch_subnets_by_vpc_name" {
  for_each = local.ff_data_fetch_vpc_by_name_subnet_groups
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.subnet_group_fetch_vpc_by_vpc_name[each.key].id]
  }
}
