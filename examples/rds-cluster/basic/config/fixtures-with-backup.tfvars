aws_region = "us-east-1"
is_enabled = true

cluster_config = [
  {
    cluster_identifier = "test-cluster-1"
  },
  {
    cluster_identifier = "test-cluster-2"
  }
]

cluster_backup_config = [
  {
    cluster_identifier      = "test-cluster-1"
    skip_final_snapshot     = true
    backup_retention_period = 10
    preferred_backup_window = "07:00-09:00"
    backup_window           = "07:00-09:00"
    copy_tags_to_snapshot   = false
  },
  {
    cluster_identifier      = "test-cluster-2"
    skip_final_snapshot     = true
    backup_retention_period = 7
    preferred_backup_window = "07:00-09:00"
    backup_window           = "07:00-09:00"
    copy_tags_to_snapshot   = false
  }
]
