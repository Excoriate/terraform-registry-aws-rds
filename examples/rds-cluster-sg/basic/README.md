<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 5.29.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_main_module"></a> [main\_module](#module\_main\_module) | ../../../modules/rds-cluster-sg | n/a |

## Resources

No resources.

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
