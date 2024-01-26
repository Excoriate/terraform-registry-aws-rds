aws_region = "us-east-1"
is_enabled = true

db_proxy_config = [
  {
    name = "db-proxy-1"
  }
]

db_proxy_auth_secrets_config = [
  {
    name       = "db-proxy-1"
    secret_arn = "arn:aws:secretsmanager:us-east-1:857007865582:secret:test/terraform-1C6tpH"
  }
]

db_proxy_timeouts_config = [
  {
    name   = "db-proxy-1"
    create = "60m"
    update = "60m"
    delete = "60m"
  }
]

db_proxy_default_target_group_config = [
  {
    name = "db-proxy-1"
  }
]
