resource "aws_db_proxy" "this" {
  for_each            = local.db_proxy_config_create
  name                = each.value["name"]
  debug_logging       = each.value["debug_logging"]
  engine_family       = each.value["engine_family"]
  idle_client_timeout = each.value["idle_client_timeout"]
  require_tls         = each.value["require_tls"]
  role_arn            = local.is_db_proxy_iam_role_default_enabled ? lookup(aws_iam_role.this, each.value["role_arn"], null) : lookup(local.db_proxy_role_config_create, each.value["role_arn"], "")
  vpc_subnet_ids      = []
  tags                = var.tags
}
