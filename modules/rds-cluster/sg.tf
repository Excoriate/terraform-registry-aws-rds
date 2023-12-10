locals {
  ff_resource_create_sg                         = !lookup(local.cluster_security_groups_config, "create", false) ? {} : local.cluster_security_groups_config["resource"]
  ff_resource_create_extra_sg_group_ids_allowed = !lookup(local.cluster_security_groups_allowed_config, "create", false) ? {} : local.cluster_security_groups_allowed_config["resource"]
}

resource "aws_security_group" "this" {
  for_each    = local.ff_resource_create_sg
  name        = format("%s-default-sg", each.value["cluster_identifier"])
  description = format("Security group for %s", each.value["cluster_identifier"])
  vpc_id      = lookup(each.value, "vpc_id", null) != null ? data.aws_vpc.vpc_from_vpc_id[each.key].id : lookup(each.value, "vpc_name", null) != null ? data.aws_vpc.vpc_from_vpc_name[each.key].id : null
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_database_members" {
  for_each = { for k, v in local.ff_resource_create_sg : k => v if lookup(v, "allow_traffic_from_database_members", false) }

  description       = "Allow inbound traffic from database members"
  type              = "ingress"
  from_port         = lookup(each.value, "db_port", 0)
  to_port           = lookup(each.value, "db_port", 0)
  protocol          = "tcp"
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
  self              = true
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_security_group_ids" {
  for_each = local.ff_resource_create_extra_sg_group_ids_allowed

  description              = "Allow inbound traffic from security group ids explicitly passed in the configuration"
  type                     = "ingress"
  from_port                = lookup(each.value, "db_port", 0)
  to_port                  = lookup(each.value, "db_port", 0)
  protocol                 = "tcp"
  source_security_group_id = each.value["security_group_id"]
  security_group_id        = join("", [for sg in aws_security_group.this : sg.id if sg != null])
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_cidr_blocks" {
  for_each          = { for k, v in local.ff_resource_create_sg : k => v if length(lookup(v, "allow_traffic_from_cidr_blocks", [])) != 0 }
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = lookup(each.value, "db_port", 0)
  to_port           = lookup(each.value, "db_port", 0)
  protocol          = "tcp"
  cidr_blocks       = lookup(local.ff_resource_create_sg[each.key], "allow_traffic_from_cidr_blocks", [])
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
}

resource "aws_security_group_rule" "allow_outbound_all_traffic" {
  for_each          = { for k, v in local.ff_resource_create_sg : k => v if lookup(v, "allow_all_outbound_traffic", false) }
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
}

resource "aws_security_group_rule" "allow_inbound_all_traffic" {
  for_each          = { for k, v in local.ff_resource_create_sg : k => v if lookup(v, "allow_all_inbound_traffic", false) }
  description       = "Allow inbound traffic"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
}
