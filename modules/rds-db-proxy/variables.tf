variable "is_enabled" {
  type        = bool
  description = <<EOF
  Whether this module will be created or not. It is useful, for stack-composite
modules that conditionally includes resources provided by this module..
EOF
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}

###################################
# AWS and provider's specific configuration
###################################
variable "db_proxy_config" {
  type = list(object({
    name                = string
    debug_logging       = optional(bool, false)
    engine_family       = optional(string, "POSTGRESQL")
    idle_client_timeout = optional(number, 1800)
    require_tls         = optional(bool, true)
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy. It supports many proxys that can be created by this module. The following attributes are supported:
  - name: The name of the database proxy.
  - debug_logging: Whether the proxy includes detailed information about SQL statements in its logs
  - engine_family: The kind of database engine that the proxy will connect to. Valid values: MYSQL or POSTGRESQL, by
  default it's set in POSTGRESQL.
  - idle_client_timeout: The number of seconds that a connection to the proxy can be inactive before the proxy disconnects
  it. Setting this parameter to 0 means never timeout. Default is 1800.
  - require_tls: Whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By default
  it's set to true.
EOF
}

variable "db_proxy_role_config" {
  type = list(object({
    name                = string
    existing_role_arn   = optional(string)
    attach_policies_arn = optional(list(string))
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy role. If this object is not passed, the module will create a new role with
  the required permissions. The following attributes are supported:
  - name: The name of the database proxy role. It must match with the name of the database proxy given in the var.db_proxy_config
  - existing_role_arn: The ARN of an existing role to use for this database proxy.
  - attach_policies_arn: The ARNs of the policies that the proxy role will assume. If this attribute is not passed, the
  module will attach the required policies to the role.
EOF
}

variable "db_proxy_auth_secrets_config" {
  type = list(object({
    name       = string
    secret_arn = string
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy authentication, when the option selected is 'SECRETS'. The following attributes are supported:
  - name: The name of the database proxy authentication.
  - secret_arn: The Amazon Resource Name (ARN) representing the secret that the proxy uses to authenticate to the RDS
EOF
}

variable "db_proxy_timeouts_config" {
  type = list(object({
    name   = string
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  }))
  default     = null
  description = <<EOF
  The timeouts block allows you to specify timeouts for certain actions:
  - name: The name of the database proxy.
  - create: (Default 30m) Used for creating the database proxy.
  - update: (Default 30m) Used for updating the database proxy.
  - delete: (Default 30m) Used for deleting the database proxy.
EOF
}

variable "db_proxy_default_target_group_config" {
  type = list(object({
    name = string
    connection_pool_config = optional(object({
      connection_borrow_timeout    = optional(number, 120)
      init_query                   = optional(string)
      max_connections_percent      = optional(number, 100)
      max_idle_connections_percent = optional(number, 50)
      session_pinning_filters      = optional(list(string))
    }))
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy default target group. The following attributes are supported:
  - name: The name of the database proxy default target group.
  - connection_pool_config: It's the actual connection pool configuration. It supports the following attributes:
  - connection_borrow_timeout: The number of seconds for a proxy to wait for a connection to become available in the
  connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are
  busy with client sessions.
  - init_query: One or more SQL statements for the proxy to run when opening each new database connection. Typically used
  with SET statements to make sure that each connection has identical settings such as time zone and character set.
  - max_connections_percent: The maximum size of the connection pool for each target in a target group. For Aurora MySQL,
  it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster used by
  the target group.
  - max_idle_connections_percent: Controls how actively the proxy closes idle database connections in the connection
  pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy
  to close idle client connections and return the underlying database connections to the connection pool. For Aurora
  MySQL, it is expressed as a percentage of the max_connections setting for the RDS DB instance or Aurora DB cluster
  used by the target group.
  - session_pinning_filters: Each item in the list represents a class of SQL operations that normally cause all later
  statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in
  the list exempts that class of SQL operations from the pinning behavior.
EOF
}

variable "db_proxy_target_config" {
  type = list(object({
    name                   = string
    db_instance_identifier = string
    db_cluster_identifier  = string
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy target. The following attributes are supported:
  - name: The name of the database proxy target.
  - db_instance_identifier: The identifier for the RDS DB instance or Aurora DB cluster that the proxy connects to.
  - db_cluster_identifier: The identifier for the RDS DB instance or Aurora DB cluster that the proxy connects to.
EOF
}

variable "db_proxy_networking_config" {
  type = list(object({
    name                   = string
    vpc_security_group_ids = list(string)
    vpc_subnet_ids         = list(string)
  }))
  default     = null
  description = <<EOF
  The configuration of the database proxy networking. The following attributes are supported:
  - name: The name of the database proxy networking.
  - vpc_security_group_ids: The identifiers of the VPC security groups for this database proxy.
  - vpc_subnet_ids: The identifiers of the VPC subnets for this database proxy.
EOF
}
