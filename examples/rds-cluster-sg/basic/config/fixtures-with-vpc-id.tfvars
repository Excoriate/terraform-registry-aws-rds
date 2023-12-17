aws_region = "us-east-1"
is_enabled = true

security_group_config = {
  name    = "test"
  db_port = 3306
}

vpc_config = {
  name   = "test"
  vpc_id = "vpc-0195e95ec40bc7da8"
}
