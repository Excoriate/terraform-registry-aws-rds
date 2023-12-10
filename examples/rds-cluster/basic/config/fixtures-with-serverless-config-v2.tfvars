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

cluster_serverless_config = {
  cluster_identifier   = "test-cluster-1"
  enable_http_endpoint = true
  scaling_configuration_for_v2 = {
    max_capacity = 4
    min_capacity = 2
  }
}
