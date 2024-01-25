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
  source                       = "../../../modules/rds-db-proxy"
  is_enabled                   = var.is_enabled
  db_proxy_config              = var.db_proxy_config
  db_proxy_role_config         = var.db_proxy_role_config
  db_proxy_auth_secrets_config = var.db_proxy_auth_secrets_config
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
| <a name="input_db_proxy_role_config"></a> [db\_proxy\_role\_config](#input\_db\_proxy\_role\_config) | The configuration of the database proxy role. If this object is not passed, the module will create a new role with<br>  the required permissions. The following attributes are supported:<br>  - name: The name of the database proxy role. It must match with the name of the database proxy given in the var.db\_proxy\_config<br>  - existing\_role\_arn: The ARN of an existing role to use for this database proxy.<br>  - attach\_policies\_arn: The ARNs of the policies that the proxy role will assume. If this attribute is not passed, the<br>  module will attach the required policies to the role. | <pre>list(object({<br>    name                = string<br>    existing_role_arn   = optional(string)<br>    attach_policies_arn = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
<!-- END_TF_DOCS -->
