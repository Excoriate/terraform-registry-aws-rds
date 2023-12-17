aws_region = "us-east-1"
is_enabled = true

security_group_config = {
  name    = "test"
  db_port = 5432
}

vpc_config = {
  name     = "test"
  vpc_name = "tsn-sandbox-us-east-1-network-core-cross-vpc-backbone"
}
