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
