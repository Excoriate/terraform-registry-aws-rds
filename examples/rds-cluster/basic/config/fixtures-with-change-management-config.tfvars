aws_region = "us-east-1"
is_enabled = true

cluster_config = {
  cluster_identifier = "test-cluster-1"
}

cluster_backup_config = {
  cluster_identifier      = "test-cluster-1"
  skip_final_snapshot     = true
  preferred_backup_window = "01:00-03:00"
}

cluster_change_management_config = {
  cluster_identifier           = "test-cluster-1"
  apply_immediately            = true
  allow_major_version_upgrade  = true
  preferred_maintenance_window = "sun:07:00-sun:09:00"
}
