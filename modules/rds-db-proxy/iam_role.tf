locals {
  default_role_name = "db-default"
}

data "aws_iam_policy_document" "assume_role" {
  for_each = !local.is_db_proxy_iam_role_default_enabled ? {} : local.db_proxy_config_create

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "this" {
  for_each           = !local.is_db_proxy_iam_role_default_enabled ? {} : local.db_proxy_config_create
  name               = format("%s-%s", each.key, local.default_role_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags               = var.tags
}
