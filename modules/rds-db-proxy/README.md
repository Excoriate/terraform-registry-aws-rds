<!-- BEGIN_TF_DOCS -->
# ☁️ AWS RDS Proxy
## Description

This module is used to create an AWS RDS Proxy. The current capabilities are supported:
* 🚀 Create an AWS RDS Proxy
* 🚀 Create an AWS RDS Proxy Target Group

For more information about the RDS DB Proxy, please query: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy

---
## Example
Examples of this module's usage are available in the [examples](./examples) folder.

```hcl
module "main_module" {
  source                               = "../../../modules/rds-db-proxy"
  is_enabled                           = var.is_enabled
  db_proxy_config                      = var.db_proxy_config
  db_proxy_role_config                 = var.db_proxy_role_config
  db_proxy_auth_secrets_config         = var.db_proxy_auth_secrets_config
  db_proxy_timeouts_config             = var.db_proxy_timeouts_config
  db_proxy_default_target_group_config = var.db_proxy_default_target_group_config
  db_proxy_target_config               = var.db_proxy_target_config
}
```

For module composition, It's recommended to take a look at the module's `outputs` to understand what's available:
```hcl
## ---------------------------------------------------------------------------------------------------------------------
## GENERAL-PURPOSE OUTPUTS
## This section contains all the general-purpose outputs of the module.
## ---------------------------------------------------------------------------------------------------------------------
output "is_enabled" {
  value       = var.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = var.tags
  description = "The tags set for the module."
}

/*
-------------------------------------
Custom outputs
-------------------------------------
*/
// FIXME: Remove, refactor or change. (Template)
```
---

## Module's documentation
(This documentation is auto-generated using [terraform-docs](https://terraform-docs.io))
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_proxy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) | resource |
| [aws_db_proxy_default_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) | resource |
| [aws_db_proxy_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 5.29.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0, < 3.6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_proxy_auth_secrets_config"></a> [db\_proxy\_auth\_secrets\_config](#input\_db\_proxy\_auth\_secrets\_config) | The configuration of the database proxy authentication, when the option selected is 'SECRETS'. The following attributes are supported:<br>  - name: The name of the database proxy authentication.<br>  - secret\_arn: The Amazon Resource Name (ARN) representing the secret that the proxy uses to authenticate to the RDS | <pre>list(object({<br>    name       = string<br>    secret_arn = string<br>  }))</pre> | `null` | no |
| <a name="input_db_proxy_config"></a> [db\_proxy\_config](#input\_db\_proxy\_config) | The configuration of the database proxy. It supports many proxys that can be created by this module. The following attributes are supported:<br>  - name: The name of the database proxy.<br>  - debug\_logging: Whether the proxy includes detailed information about SQL statements in its logs<br>  - engine\_family: The kind of database engine that the proxy will connect to. Valid values: MYSQL or POSTGRESQL, by<br>  default it's set in POSTGRESQL.<br>  - idle\_client\_timeout: The number of seconds that a connection to the proxy can be inactive before the proxy disconnects<br>  it. Setting this parameter to 0 means never timeout. Default is 1800.<br>  - require\_tls: Whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By default<br>  it's set to true. | <pre>list(object({<br>    name                = string<br>    debug_logging       = optional(bool, false)<br>    engine_family       = optional(string, "POSTGRESQL")<br>    idle_client_timeout = optional(number, 1800)<br>    require_tls         = optional(bool, true)<br>  }))</pre> | `null` | no |
| <a name="input_db_proxy_default_target_group_config"></a> [db\_proxy\_default\_target\_group\_config](#input\_db\_proxy\_default\_target\_group\_config) | The configuration of the database proxy default target group. The following attributes are supported:<br>  - name: The name of the database proxy default target group.<br>  - connection\_pool\_config: It's the actual connection pool configuration. It supports the following attributes:<br>  - connection\_borrow\_timeout: The number of seconds for a proxy to wait for a connection to become available in the<br>  connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are<br>  busy with client sessions.<br>  - init\_query: One or more SQL statements for the proxy to run when opening each new database connection. Typically used<br>  with SET statements to make sure that each connection has identical settings such as time zone and character set.<br>  - max\_connections\_percent: The maximum size of the connection pool for each target in a target group. For Aurora MySQL,<br>  it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster used by<br>  the target group.<br>  - max\_idle\_connections\_percent: Controls how actively the proxy closes idle database connections in the connection<br>  pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy<br>  to close idle client connections and return the underlying database connections to the connection pool. For Aurora<br>  MySQL, it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster<br>  used by the target group.<br>  - session\_pinning\_filters: Each item in the list represents a class of SQL operations that normally cause all later<br>  statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in<br>  the list exempts that class of SQL operations from the pinning behavior. | <pre>list(object({<br>    name = string<br>    connection_pool_config = optional(object({<br>      connection_borrow_timeout    = optional(number, 120)<br>      init_query                   = optional(string)<br>      max_connections_percent      = optional(number, 100)<br>      max_idle_connections_percent = optional(number, 50)<br>      session_pinning_filters      = optional(list(string))<br>    }))<br>  }))</pre> | `null` | no |
| <a name="input_db_proxy_role_config"></a> [db\_proxy\_role\_config](#input\_db\_proxy\_role\_config) | The configuration of the database proxy role. If this object is not passed, the module will create a new role with<br>  the required permissions. The following attributes are supported:<br>  - name: The name of the database proxy role. It must match with the name of the database proxy given in the var.db\_proxy\_config<br>  - existing\_role\_arn: The ARN of an existing role to use for this database proxy.<br>  - attach\_policies\_arn: The ARNs of the policies that the proxy role will assume. If this attribute is not passed, the<br>  module will attach the required policies to the role. | <pre>list(object({<br>    name                = string<br>    existing_role_arn   = optional(string)<br>    attach_policies_arn = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_db_proxy_target_config"></a> [db\_proxy\_target\_config](#input\_db\_proxy\_target\_config) | The configuration of the database proxy target. The following attributes are supported:<br>  - name: The name of the database proxy target.<br>  - db\_instance\_identifier: The identifier for the RDS DB instance or Aurora DB cluster that the proxy connects to.<br>  - db\_cluster\_identifier: The identifier for the RDS DB instance or Aurora DB cluster that the proxy connects to. | <pre>list(object({<br>    name                   = string<br>    db_instance_identifier = string<br>    db_cluster_identifier  = string<br>  }))</pre> | `null` | no |
| <a name="input_db_proxy_timeouts_config"></a> [db\_proxy\_timeouts\_config](#input\_db\_proxy\_timeouts\_config) | The timeouts block allows you to specify timeouts for certain actions:<br>  - name: The name of the database proxy.<br>  - create: (Default 30m) Used for creating the database proxy.<br>  - update: (Default 30m) Used for updating the database proxy.<br>  - delete: (Default 30m) Used for deleting the database proxy. | <pre>list(object({<br>    name   = string<br>    create = optional(string, "30m")<br>    update = optional(string, "30m")<br>    delete = optional(string, "30m")<br>  }))</pre> | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
<!-- END_TF_DOCS -->