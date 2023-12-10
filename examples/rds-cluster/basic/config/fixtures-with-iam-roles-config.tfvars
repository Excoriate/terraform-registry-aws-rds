aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
  engine_mode        = "provisioned"
}

cluster_backup_config = {
  cluster_identifier      = "test-cluster-1"
  skip_final_snapshot     = true
  preferred_backup_window = "01:00-03:00"
}


cluster_timeouts_config = {
  cluster_identifier = "test-cluster-1"
  create             = "30m"
  delete             = "30m"
}

cluster_iam_roles_config = {
  cluster_identifier                  = "test-cluster-1"
  iam_database_authentication_enabled = true
}
