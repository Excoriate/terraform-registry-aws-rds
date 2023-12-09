locals {
  ff_resource_create_sg = lookup(local.cluster_security_groups_config, "create", false) ? local.cluster_security_groups_config : {}

  ff_resource_create_sg_rule_allow_traffic_from_database_members = !lookup(local.ff_resource_create_sg, "allow_traffic_from_database_members", false) ? {} : local.ff_resource_create_sg

  ff_resource_create_sg_rule_allow_traffic_from_security_group_ids = lookup(local.ff_resource_create_sg, "allow_traffic_from_security_group_ids", null) == null ? {} : local.ff_resource_create_sg

  ff_resource_create_sg_rule_allow_traffic_from_cidr_blocks = lookup(local.ff_resource_create_sg, "allow_traffic_from_cidr_blocks", null) == null ? {} : local.ff_resource_create_sg

  ff_resource_create_sg_rule_allow_all_outbound_traffic = lookup(local.ff_resource_create_sg, "allow_all_outbound_traffic", false) ? {} : local.ff_resource_create_sg

  ff_resource_create_sg_rule_allow_all_inbound_traffic = lookup(local.ff_resource_create_sg, "allow_all_inbound_traffic", false) ? {} : local.ff_resource_create_sg
}

resource "aws_security_group" "this" {
  for_each    = local.ff_resource_create_sg
  name        = format("%s-default-sg", each.value["cluster_identifier"])
  description = format("Security group for %s", each.value["cluster_identifier"])
  vpc_id      = !local.is_cluster_security_groups_config_enabled ? null : lookup(local.cluster_security_groups_config[each.key]["options"], "fetch_vpc_id_from_vpc_id", null) ? data.aws_vpc.vpc_from_vpc_id[each.key].id : lookup(local.cluster_security_groups_config[each.key]["options"], "fetch_vpc_id_from_vpc_name", null) ? data.aws_vpc.vpc_from_vpc_name[each.key].id : null

  lifecycle {
    precondition {
      error_message = "Either the VPC id or the VPC name should be provided."
      condition     = local.cluster_security_groups_config == null || try(lookup(local.cluster_security_groups_config, each.key)["options"]["fetch_vpc_id_from_vpc_id"], null) != null || try(lookup(local.cluster_security_groups_config, each.key)["options"]["fetch_vpc_id_from_vpc_name"], null) != null
    }

    #    precondition {
    #      error_message = "If the VPC ID is provided, should be a valid VPC id with the proper format"
    #      condition     = local.cluster_security_groups_config == null || lookup(local.cluster_security_groups_config[each.key]["options"], "fetch_vpc_id_from_vpc_id", null) ? can(regex("vpc-[a-z0-9]{8,17}", data.aws_vpc.vpc_from_vpc_id[each.key].id)) : true
    #    }
    #
    #    precondition {
    #      error_message = "Either of the VPC id or the VPC name should be provided, but not both."
    #      condition     = local.cluster_security_groups_config == null || lookup(local.cluster_security_groups_config[each.key]["options"], "fetch_vpc_id_from_vpc_id", null) && lookup(local.cluster_security_groups_config[each.key]["options"], "fetch_vpc_id_from_vpc_name", null)
    #    }
  }
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_database_members" {
  for_each = local.ff_resource_create_sg_rule_allow_traffic_from_database_members

  description       = "Allow inbound traffic from database members"
  type              = "ingress"
  from_port         = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  to_port           = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.this[each.key].id)
  self              = true
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_security_group_ids" {
  for_each = local.ff_resource_create_sg_rule_allow_traffic_from_security_group_ids

  description              = "Allow inbound traffic from security group ids explicitly passed in the configuration"
  type                     = "ingress"
  from_port                = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  to_port                  = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  protocol                 = "tcp"
  source_security_group_id = lookup(local.cluster_security_groups_config[each.key], "allow_traffic_from_security_group_ids", [])
  security_group_id        = join("", aws_security_group.this[each.key].id)
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_cidr_blocks" {
  for_each          = local.ff_resource_create_sg_rule_allow_traffic_from_cidr_blocks
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  to_port           = lookup(local.cluster_security_groups_config[each.key], "db_port", 0)
  protocol          = "tcp"
  cidr_blocks       = lookup(local.cluster_security_groups_config[each.key], "allow_traffic_from_cidr_blocks", [])
  security_group_id = join("", aws_security_group.this[each.key].id)
}

resource "aws_security_group_rule" "allow_outbound_all_traffic" {
  for_each          = local.ff_resource_create_sg_rule_allow_all_outbound_traffic
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this[each.key].id)
}

resource "aws_security_group_rule" "allow_inbound_all_traffic" {
  for_each          = local.ff_resource_create_sg_rule_allow_all_inbound_traffic
  description       = "Allow inbound traffic"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this[each.key].id)
}
