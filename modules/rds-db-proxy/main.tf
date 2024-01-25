resource "aws_db_proxy" "this" {
  for_each            = local.db_proxy_config_create
  name                = each.value["name"]
  debug_logging       = each.value["debug_logging"]
  engine_family       = each.value["engine_family"]
  idle_client_timeout = each.value["idle_client_timeout"]
  require_tls         = each.value["require_tls"]
  role_arn            = local.is_db_proxy_iam_role_default_enabled ? [for arn in aws_iam_role.this : arn.arn][0] : [for arn_passed in local.db_proxy_role_config_create : arn_passed["arn"] if arn_passed["name"] == each.key][0]
  vpc_subnet_ids      = []
  tags                = var.tags

  #################################################
  # Auth Secrets Config
  #################################################
  dynamic "auth" {
    for_each = [for cfg in local.db_proxy_auth_secrets_config_normalised : cfg if cfg["name"] == each.key]
    iterator = proxy_auth
    content {
      auth_scheme = lookup(proxy_auth.value, "auth_scheme", null)
      secret_arn  = lookup(proxy_auth.value, "secret_arn", null)
      description = lookup(proxy_auth.value, "description", null)
    }
  }
}
