## ---------------------------------------------------------------------------------------------------------------------
## GENERAL-PURPOSE INPUT VARIABLES
## These variables have general purpose and are used to configure the module execution
## ---------------------------------------------------------------------------------------------------------------------
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

## ---------------------------------------------------------------------------------------------------------------------
## PROVIDER-SPECIFIC INPUT VARIABLES
## These variables are used to configure the provider-specific resources
## ---------------------------------------------------------------------------------------------------------------------
variable "security_group_config" {
  type = object({
    name                                    = string
    db_port                                 = number
    enable_inbound_all                      = optional(bool, false)
    enable_inbound_cidr_blocks              = optional(list(string), [])
    enable_outbound_all                     = optional(bool, false)
    enable_traffic_between_database_members = optional(bool, false)
  })
  default     = null
  description = <<EOF
  The rules configuration for the security group. The default value is null, which means that no rules will be created.
  The current supported attributes are:
  - name: The name of the rules-set. It's also used to name the security group.
  - db_port: The port to open for database connections.
  - enable_inbound_all: Whether to enable all inbound traffic. The default value is false.
  - enable_inbound_cidr_blocks: Whether to enable inbound traffic from the specified CIDR blocks. The default value is [].
  - enable_outbound_all: Whether to enable all outbound traffic. The default value is false.
  - enable_traffic_between_database_members: Whether to enable traffic between database members. The default value is false.
EOF
}

variable "vpc_config" {
  type = object({
    name     = string
    vpc_id   = optional(string)
    vpc_name = optional(string)
  })
  default     = null
  description = <<EOF
  The network configuration for the security group. The default value is null, which means that no network configuration will be created.
  The current supported attributes are:
  - name: The name of the network configuration. It's also used to name the security group. Both should match.
  - vpc_id: The ID of the VPC where the security group will be created.
  - vpc_name: The name of the VPC where the security group will be created. It's used to retrieve the VPC ID.
EOF
}

variable "security_group_ids_to_allow_inbound_traffic" {
  type = list(object({
    id        = string
    name      = string
    rule_name = string
  }))
  description = <<EOF
  The IDs of the security groups to allow inbound traffic from.
  The current supported attributes are:
  - id: The ID of the security group.
  - name: The name of the security group. It's a friendly (or user's designed name, and it's used for computing
mapping values, and internal logic. Ensure it matches the name of the security group configuration
passed to the input variable var.security_group_config.
  - rule_name: The name of the rule to create. It's used to name the rule.
EOF
  default     = null
}

variable "security_group_ids_to_allow_outbound_traffic" {
  type = list(object({
    id        = string
    name      = string
    rule_name = string
  }))
  default     = null
  description = <<EOF
  The IDs of the security groups to allow outbound traffic to.
  The current supported attributes are:
  - id: The ID of the security group.
  - name: The name of the security group. It's a friendly (or user's designed name, and it's used for computing
mapping values, and internal logic. Ensure it matches the name of the security group configuration
passed to the input variable var.security_group_config.
  - rule_name: The name of the rule to create. It's used to name the rule.
EOF
}
