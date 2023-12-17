data "aws_vpc" "sg_vpc_by_id" {
  for_each = { for k, v in local.vpc_config_create : k => v if lookup(v, "vpc_id", null) != null }
  id       = each.value["vpc_id"]
}

data "aws_vpc" "sg_vpc_by_name" {
  for_each = { for k, v in local.vpc_config_create : k => v if lookup(v, "vpc_name", null) != null }
  filter {
    name   = "tag:Name"
    values = [each.value["vpc_name"]]
  }
}
