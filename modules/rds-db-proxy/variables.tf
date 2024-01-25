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
