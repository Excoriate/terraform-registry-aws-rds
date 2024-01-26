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

db_proxy_networking_config = [
  {
    name = "db-proxy-1"
    vpc_subnet_ids = [
      "subnet-0ec873190e3682e76",
      "subnet-0ddfb2c92c34077ba",
    ]
    vpc_security_group_ids = [
      "sg-04928005a915d8538"
    ]

  }
]
