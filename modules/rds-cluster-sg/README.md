<!-- BEGIN_TF_DOCS -->
# ☁️ AWS RDS Cluster instances
## Description

This module is used to create an AWS RDS Cluster instances. The current capabilities are supported:
* 🚀 Create an AWS RDS Cluster instances

For more information about cluster instances, please visit its official documentation [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html).
For more information about the resource configuration using Terraform, please visit the official documentation [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance).

A cluster instance in the context of Aurora is a database instance that is part of an Aurora DB cluster. Each instance in a DB cluster runs the Aurora engine and contains a copy
of the data in the DB cluster. You can run SQL statements on a cluster instance just as you would on a standalone instance except that you must connect to a specific instance endpoint for the
instance. You can also run SQL statements on the primary instance of an Aurora DB cluster and have those statements automatically routed to the appropriate instance in the DB cluster for execution. For
more information, see [Aurora DB cluster endpoints](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Connecting.html#Aurora.Connecting.Cluster.Endpoints).

---
## Example
Examples of this module's usage are available in the [examples](./examples) folder.

```hcl
module "main_module" {
  source     = "../../../modules/rds-cluster-instance"
  is_enabled = var.is_enabled
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
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.random_text](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 5.29.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0, < 3.6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
<!-- END_TF_DOCS -->
