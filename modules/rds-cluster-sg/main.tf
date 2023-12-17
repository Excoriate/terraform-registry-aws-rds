resource "aws_security_group" "this" {
  for_each    = local.sg_config_create
  name        = each.value["name"]
  description = each.value["description"]
  vpc_id      = lookup(local.vpc_config_create[each.key], "vpc_id", null) != null ? data.aws_vpc.sg_vpc_by_id[each.key].id : data.aws_vpc.sg_vpc_by_name[each.key].id
  tags        = var.tags
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_database_members" {
  for_each = { for k, v in local.sg_config_create : k => v if lookup(v, "enable_traffic_between_database_members", false) == true }

  description       = "Allow inbound traffic from database members"
  type              = "ingress"
  from_port         = lookup(each.value, "db_port", 0)
  to_port           = lookup(each.value, "db_port", 0)
  protocol          = "tcp"
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
  self              = true

  depends_on = [aws_security_group.this]
}

resource "aws_security_group_rule" "enable_inbound_all" {
  for_each = { for k, v in local.sg_config_create : k => v if lookup(v, "enable_inbound_all", false) == true }

  description       = "Allow inbound traffic from all"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])

  depends_on = [aws_security_group.this]
}

resource "aws_security_group_rule" "enable_outbound_all" {
  for_each = { for k, v in local.sg_config_create : k => v if lookup(v, "enable_outbound_all", false) == true }

  description       = "Allow outbound traffic to all"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])

  depends_on = [aws_security_group.this]
}

resource "aws_security_group_rule" "enable_inbound_cidr_blocks" {
  for_each = { for k, v in local.sg_config_create : k => v if length(lookup(v, "enable_inbound_cidr_blocks", [])) > 0 }

  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = lookup(each.value, "db_port", 0)
  to_port           = lookup(each.value, "db_port", 0)
  protocol          = "tcp"
  cidr_blocks       = lookup(each.value, "cidr_blocks", [])
  security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])

  depends_on = [aws_security_group.this]
}


resource "aws_security_group_rule" "enable_inbound_from_security_group_ids" {
  for_each = local.sg_ids_inbound_create

  description              = "Allow inbound traffic from security group IDs"
  type                     = each.value["type"]
  from_port                = lookup(local.sg_config_create[each.value["name"]], "db_port", 0)
  to_port                  = lookup(local.sg_config_create[each.value["name"]], "db_port", 0)
  protocol                 = each.value["protocol"]
  source_security_group_id = each.value["id"]
  security_group_id        = join("", [for sg in aws_security_group.this : sg.id if sg != null])
}

resource "aws_security_group_rule" "enable_outbound_to_security_group_ids" {
  for_each = local.sg_ids_outbound_create

  description              = "Allow outbound traffic to security group IDs"
  type                     = each.value["type"]
  from_port                = lookup(local.sg_config_create[each.value["name"]], "db_port", 0)
  to_port                  = lookup(local.sg_config_create[each.value["name"]], "db_port", 0)
  protocol                 = each.value["protocol"]
  source_security_group_id = join("", [for sg in aws_security_group.this : sg.id if sg != null])
  security_group_id        = each.value["id"]
}
