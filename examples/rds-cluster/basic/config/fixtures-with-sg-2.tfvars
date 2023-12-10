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

cluster_security_groups_config = {
  cluster_identifier                  = "test-cluster-1"
  db_port                             = 5432
  allow_traffic_from_database_members = true
  allow_all_outbound_traffic          = true
  allow_all_inbound_traffic           = true
}
