<!-- BEGIN_TF_DOCS -->
# ☁️ AWS RDS cluster Security group
## Description

This module provides a RDS Security group resource in AWS, with out-of-the-box features:
* 🚀 Allow ingress traffic from a list of CIDR blocks
* 🚀 Allow ingress traffic from a list of security groups
* 🚀 Allow outbound traffic to a list of CIDR blocks
* 🚀 Allow outbound traffic to a list of security groups
* 🚀 Allow access between Db members of the same cluster

For more information, please check the [official documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html).

---
## Example
Examples of this module's usage are available in the [examples](./examples) folder.

```hcl
module "main_module" {
  source                                       = "../../../modules/rds-cluster-sg"
  is_enabled                                   = var.is_enabled
  tags                                         = var.tags
  security_group_config                        = var.security_group_config
  vpc_config                                   = var.vpc_config
  security_group_ids_to_allow_inbound_traffic  = var.security_group_ids_to_allow_inbound_traffic
  security_group_ids_to_allow_outbound_traffic = var.security_group_ids_to_allow_outbound_traffic
}
```

Also, and advanced version of it with inbound and outbound rules for security group ids is available in the [examples](./examples) folder.

```hcl
resource "aws_security_group" "example_sg" {
  name        = "example_sg"
  description = "example_sg"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}

resource "aws_security_group" "example_sg_2" {
  name        = "example_sg-2"
  description = "example_sg-2"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}

resource "aws_security_group" "example_sg_3" {
  name        = "example_sg-3"
  description = "example_sg-3"
  vpc_id      = "vpc-0195e95ec40bc7da8"
}


module "main_module" {
  source     = "../../../modules/rds-cluster-sg"
  is_enabled = var.is_enabled
  tags       = var.tags
  security_group_config = {
    name                                    = "example-test-advanced"
    db_port                                 = 5432
    enable_inbound_all                      = true
    enable_outbound_all                     = true
    enable_traffic_between_database_members = true
  }
  vpc_config = {
    name     = "example-test-advanced"
    vpc_name = "tsn-sandbox-us-east-1-network-core-cross-vpc-backbone"
  }

  security_group_ids_to_allow_inbound_traffic = [
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg.id
      rule_name = "example_sg"
    },
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg_2.id
      rule_name = "example_sg_2"
    },
  ]

  security_group_ids_to_allow_outbound_traffic = [
    {
      name      = "example-test-advanced"
      id        = aws_security_group.example_sg_3.id
      rule_name = "example_sg_3"
    },
  ]
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

## ---------------------------------------------------------------------------------------------------------------------
## OUTPUT-MY-INPUT pattern
## Useful to show what's entered as input, and help in troubleshooting.
## ---------------------------------------------------------------------------------------------------------------------
output "vpc_config_inputs" {
  value = {
    raw        = var.vpc_config
    normalised = local.vpc_config_normalised
    created    = local.vpc_config_create
  }
  description = "The VPC configuration inputs."
}

output "rules_config_inputs" {
  value = {
    raw        = var.security_group_config
    normalised = local.sg_config_normalised
    created    = local.sg_config_create
  }
  description = "The rules configuration inputs."
}


## ---------------------------------------------------------------------------------------------------------------------
## OUTPUTS - MODULE
## This section contains all the outputs of the module.
## ---------------------------------------------------------------------------------------------------------------------
output "security_group_id" {
  value       = join("", [for security_group in aws_security_group.this : security_group.id])
  description = "The ID of the security group."
}

output "security_group_arn" {
  value       = join("", [for security_group in aws_security_group.this : security_group.arn])
  description = "The ARN of the security group."
}

output "vpc_from_id" {
  value       = [for vpc in data.aws_vpc.sg_vpc_by_id : vpc if vpc != null]
  description = "VPC configuration if it's fetched by id."
}

output "vpc_from_name" {
  value       = [for vpc in data.aws_vpc.sg_vpc_by_name : vpc if vpc != null]
  description = "VPC configuration if it's fetched by name."
}
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
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_inbound_traffic_from_database_members](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.enable_inbound_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.enable_inbound_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.enable_inbound_from_security_group_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.enable_outbound_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.enable_outbound_to_security_group_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc.sg_vpc_by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.sg_vpc_by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 5.29.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | The rules configuration for the security group. The default value is null, which means that no rules will be created.<br>  The current supported attributes are:<br>  - name: The name of the rules-set. It's also used to name the security group.<br>  - db\_port: The port to open for database connections.<br>  - enable\_inbound\_all: Whether to enable all inbound traffic. The default value is false.<br>  - enable\_inbound\_cidr\_blocks: Whether to enable inbound traffic from the specified CIDR blocks. The default value is [].<br>  - enable\_outbound\_all: Whether to enable all outbound traffic. The default value is false.<br>  - enable\_traffic\_between\_database\_members: Whether to enable traffic between database members. The default value is false. | <pre>object({<br>    name                                    = string<br>    db_port                                 = number<br>    enable_inbound_all                      = optional(bool, false)<br>    enable_inbound_cidr_blocks              = optional(list(string), [])<br>    enable_outbound_all                     = optional(bool, false)<br>    enable_traffic_between_database_members = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_security_group_ids_to_allow_inbound_traffic"></a> [security\_group\_ids\_to\_allow\_inbound\_traffic](#input\_security\_group\_ids\_to\_allow\_inbound\_traffic) | The IDs of the security groups to allow inbound traffic from.<br>  The current supported attributes are:<br>  - id: The ID of the security group.<br>  - name: The name of the security group. It's a friendly (or user's designed name, and it's used for computing<br>mapping values, and internal logic. Ensure it matches the name of the security group configuration<br>passed to the input variable var.security\_group\_config.<br>  - rule\_name: The name of the rule to create. It's used to name the rule. | <pre>list(object({<br>    id        = string<br>    name      = string<br>    rule_name = string<br>  }))</pre> | `null` | no |
| <a name="input_security_group_ids_to_allow_outbound_traffic"></a> [security\_group\_ids\_to\_allow\_outbound\_traffic](#input\_security\_group\_ids\_to\_allow\_outbound\_traffic) | The IDs of the security groups to allow outbound traffic to.<br>  The current supported attributes are:<br>  - id: The ID of the security group.<br>  - name: The name of the security group. It's a friendly (or user's designed name, and it's used for computing<br>mapping values, and internal logic. Ensure it matches the name of the security group configuration<br>passed to the input variable var.security\_group\_config.<br>  - rule\_name: The name of the rule to create. It's used to name the rule. | <pre>list(object({<br>    id        = string<br>    name      = string<br>    rule_name = string<br>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The network configuration for the security group. The default value is null, which means that no network configuration will be created.<br>  The current supported attributes are:<br>  - name: The name of the network configuration. It's also used to name the security group. Both should match.<br>  - vpc\_id: The ID of the VPC where the security group will be created.<br>  - vpc\_name: The name of the VPC where the security group will be created. It's used to retrieve the VPC ID. | <pre>object({<br>    name     = string<br>    vpc_id   = optional(string)<br>    vpc_name = optional(string)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_rules_config_inputs"></a> [rules\_config\_inputs](#output\_rules\_config\_inputs) | The rules configuration inputs. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
| <a name="output_vpc_config_inputs"></a> [vpc\_config\_inputs](#output\_vpc\_config\_inputs) | The VPC configuration inputs. |
| <a name="output_vpc_from_id"></a> [vpc\_from\_id](#output\_vpc\_from\_id) | VPC configuration if it's fetched by id. |
| <a name="output_vpc_from_name"></a> [vpc\_from\_name](#output\_vpc\_from\_name) | VPC configuration if it's fetched by name. |
<!-- END_TF_DOCS -->
