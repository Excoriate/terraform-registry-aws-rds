resource "aws_security_group" "example_sg" {
  name        = "example_sg"
  description = "example_sg"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}

resource "aws_security_group" "example_sg_2" {
  name        = "example_sg-2"
  description = "example_sg-2"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}

resource "aws_security_group" "example_sg_3" {
  name        = "example_sg-3"
  description = "example_sg-3"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}


module "main_module" {
  source     = "../../../modules/rds-cluster-sg"
  is_enabled = var.is_enabled
  tags       = var.tags
  security_group_config = {
    name                                    = "example-test-advanced"
    db_port                                 = 5432
    enable_inbound_all                      = true
    enable_outbound_all                     = true
    enable_traffic_between_database_members = true
  }
  vpc_config = {
    name     = "example-test-advanced"
    vpc_name = "tsn-sandbox-us-east-1-network-core-cross-vpc-backbone"
  }

  security_group_ids_to_allow_inbound_traffic = [
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg.id
      rule_name = "example_sg"
    },
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg_2.id
      rule_name = "example_sg_2"
    },
  ]

  security_group_ids_to_allow_outbound_traffic = [
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg_3.id
      rule_name = "example_sg_3"
    },
  ]
}
