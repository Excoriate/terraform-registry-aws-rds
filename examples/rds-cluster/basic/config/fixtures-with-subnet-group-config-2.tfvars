aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
  engine_mode        = "provisioned"
}

cluster_backup_config = {
  cluster_identifier  = "test-cluster-1"
  skip_final_snapshot = true
}

cluster_timeouts_config = {
  cluster_identifier = "test-cluster-1"
  create             = "30m"
  delete             = "30m"
}

cluster_subnet_group_config = {
  cluster_identifier = "test-cluster-1"
  vpc_name           = "tsn-sandbox-us-east-1-network-core-cross-vpc-backbone"
}
