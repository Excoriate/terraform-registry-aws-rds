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

  #################################################
  # Timeouts
  #################################################
  dynamic "timeouts" {
    for_each = [for cfg in local.db_proxy_timeouts_config_normalised : cfg if cfg["name"] == each.key]
    iterator = proxy_timeouts
    content {
      create = lookup(proxy_timeouts.value, "create", null)
      delete = lookup(proxy_timeouts.value, "delete", null)
      update = lookup(proxy_timeouts.value, "update", null)
    }
  }
}

#################################################
# Default Target group
#################################################
resource "aws_db_proxy_default_target_group" "this" {
  for_each      = local.db_proxy_default_target_group_config_create
  db_proxy_name = aws_db_proxy.this[each.key].name

  dynamic "connection_pool_config" {
    for_each = [for cfg in each.value["connection_pool_config"] : cfg]
    content {
      connection_borrow_timeout    = lookup(connection_pool_config.value, "connection_borrow_timeout", null)
      init_query                   = lookup(connection_pool_config.value, "init_query", null)
      max_connections_percent      = lookup(connection_pool_config.value, "max_connections_percent", null)
      max_idle_connections_percent = lookup(connection_pool_config.value, "max_idle_connections_percent", null)
      session_pinning_filters      = lookup(connection_pool_config.value, "session_pinning_filters", null)
    }
  }
}

#################################################
# Target
#################################################
resource "aws_db_proxy_target" "this" {
  for_each               = local.db_proxy_target_config_create
  db_instance_identifier = each.value["db_instance_identifier"]
  db_cluster_identifier  = each.value["db_cluster_identifier"]
  db_proxy_name          = aws_db_proxy.this[each.key].name
  target_group_name      = aws_db_proxy_default_target_group.this[each.key].name
}
