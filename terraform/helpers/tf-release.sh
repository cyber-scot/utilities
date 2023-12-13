
```hcl
resource "azurerm_automation_account" "aa" {
  name                          = var.automation_account_name
  location                      = var.location
  resource_group_name           = var.rg_name
  tags                          = var.tags
  sku_name                      = title(var.sku_name)
  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = var.local_authentication_enabled

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "SystemAssigned, UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  # Add dynamic block for encryption if you plan to use it
  dynamic "encryption" {
    for_each = var.key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id          = var.key_vault_key_id
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }
}


resource "azurerm_automation_module" "powershell_modules" {
  count                   = length(var.powershell_modules) > 0 ? length(var.powershell_modules) : 0
  name                    = var.powershell_modules[count.index].name
  resource_group_name     = var.rg_name
  automation_account_name = azurerm_automation_account.aa.name
  module_link {
    uri = var.powershell_modules[count.index].uri

    dynamic "hash" {
      for_each = var.powershell_modules[count.index].hash != null ? [var.powershell_modules[count.index].hash] : []
      content {
        algorithm = hash.value.algorithm
        value     = hash.value.value
      }
    }
  }
}

resource "azurerm_automation_python3_package" "python3_packages" {
  count                   = length(var.python3_packages) > 0 ? length(var.python3_packages) : 0
  name                    = var.python3_packages[count.index].name
  resource_group_name     = var.rg_name
  automation_account_name = azurerm_automation_account.aa.name
  content_uri             = var.python3_packages[count.index].content_uri
  content_version         = var.python3_packages[count.index].content_version
  hash_algorithm          = var.python3_packages[count.index].hash_algorithm
  hash_value              = var.python3_packages[count.index].hash_value
  tags                    = var.python3_packages[count.index].tags
}

resource "azurerm_automation_schedule" "schedules" {
  count                   = length(var.automation_schedule) > 0 ? length(var.automation_schedule) : 0
  name                    = var.automation_schedule[count.index].name
  resource_group_name     = var.rg_name
  automation_account_name = azurerm_automation_account.aa.name
  frequency               = var.automation_schedule[count.index].frequency
  description             = var.automation_schedule[count.index].description
  interval                = var.automation_schedule[count.index].interval
  start_time              = var.automation_schedule[count.index].start_time
  expiry_time             = var.automation_schedule[count.index].expiry_time
  timezone                = var.automation_schedule[count.index].timezone
  week_days               = var.automation_schedule[count.index].week_days
  month_days              = var.automation_schedule[count.index].month_days

  dynamic "monthly_occurrence" {
    for_each = var.automation_schedule[count.index].monthly_occurrence != null ? var.automation_schedule[count.index].monthly_occurrence : []
    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
}

resource "azurerm_automation_runbook" "runbook" {
  count                   = length(var.runbooks)
  name                    = var.runbooks[count.index].name
  location                = var.location
  resource_group_name     = var.rg_name
  automation_account_name = azurerm_automation_account.aa.name
  runbook_type            = var.runbooks[count.index].runbook_type
  log_progress            = var.runbooks[count.index].log_progress
  log_verbose             = var.runbooks[count.index].log_verbose
  description             = var.runbooks[count.index].description
  content                 = var.runbooks[count.index].content

  dynamic "publish_content_link" {
    for_each = var.runbooks[count.index].publish_content_link != null ? [var.runbooks[count.index].publish_content_link] : []
    content {
      uri     = publish_content_link.value.uri
      version = publish_content_link.value.version
      dynamic "hash" {
        for_each = publish_content_link.value.hash != null ? [publish_content_link.value.hash] : []
        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
    }
  }

  dynamic "draft" {
    for_each = var.runbooks[count.index].draft != null ? [var.runbooks[count.index].draft] : []
    content {
      edit_mode_enabled = draft.value.edit_mode_enabled

      dynamic "content_link" {
        for_each = draft.value.content_link != null ? [draft.value.content_link] : []
        content {
          uri     = content_link.value.uri
          version = content_link.value.version

          dynamic "hash" {
            for_each = content_link.value.hash != null ? [content_link.value.hash] : []
            content {
              algorithm = hash.value.algorithm
              value     = hash.value.value
            }
          }
        }
      }

      output_types = draft.value.output_types

      dynamic "parameters" {
        for_each = draft.value.parameters != null ? draft.value.parameters : []
        content {
          key           = parameters.value.key
          type          = parameters.value.type
          mandatory     = parameters.value.mandatory
          position      = parameters.value.position
          default_value = parameters.value.default_value
        }
      }
    }
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.aa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_module.powershell_modules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_module) | resource |
| [azurerm_automation_python3_package.python3_packages](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_python3_package) | resource |
| [azurerm_automation_runbook.runbook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.schedules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | The name of the automation account | `string` | n/a | yes |
| <a name="input_automation_schedule"></a> [automation\_schedule](#input\_automation\_schedule) | Configuration for the Automation Schedule | <pre>list(object({<br>    name        = string<br>    frequency   = string<br>    description = optional(string)<br>    interval    = optional(number)<br>    start_time  = optional(string)<br>    expiry_time = optional(string)<br>    timezone    = optional(string)<br>    week_days   = optional(list(string))<br>    month_days  = optional(list(number))<br>    monthly_occurrence = optional(list(object({<br>      day        = string<br>      occurrence = number<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_key_vault_key_id"></a> [key\_vault\_key\_id](#input\_key\_vault\_key\_id) | The ID of the Key Vault Key which should be used to Encrypt the data in this Automation Account. | `string` | `null` | no |
| <a name="input_local_authentication_enable"></a> [local\_authentication\_enable](#input\_local\_authentication\_enable) | Whether local authentication enabled | `bool` | `false` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether local authentication should be anbled | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_powershell_modules"></a> [powershell\_modules](#input\_powershell\_modules) | List of PowerShell modules to be added | <pre>list(object({<br>    name = string<br>    uri  = string<br>    hash = optional(object({<br>      algorithm = optional(string)<br>      value     = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | If public network access is enabled | `bool` | `false` | no |
| <a name="input_python3_packages"></a> [python3\_packages](#input\_python3\_packages) | List of Python3 packages to be added | <pre>list(object({<br>    name            = string<br>    content_uri     = string<br>    content_version = optional(string)<br>    hash_algorithm  = optional(string)<br>    hash_value      = optional(string)<br>    tags            = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_runbooks"></a> [runbooks](#input\_runbooks) | List of runbooks to be created. | <pre>list(object({<br>    name         = string<br>    runbook_type = string<br>    log_progress = bool<br>    log_verbose  = bool<br>    description  = optional(string)<br>    content      = optional(string)<br>    publish_content_link = optional(object({<br>      uri     = string<br>      version = optional(string)<br>      hash = optional(object({<br>        algorithm = string<br>        value     = string<br>      }))<br>    }))<br>    draft = optional(object({<br>      edit_mode_enabled = bool<br>      content_link = optional(object({<br>        uri     = string<br>        version = optional(string)<br>        hash = optional(object({<br>          algorithm = string<br>          value     = string<br>        }))<br>      }))<br>      output_types = optional(list(string))<br>      parameters = optional(list(object({<br>        key           = string<br>        type          = string<br>        mandatory     = optional(bool)<br>        position      = optional(number)<br>        default_value = optional(string)<br>      })))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU of the automation account, Basic is the only supported value | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | The User Assigned Managed Identity ID to be used for accessing the Customer Managed Key for encryption. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aa_dsc_primary_access_key"></a> [aa\_dsc\_primary\_access\_key](#output\_aa\_dsc\_primary\_access\_key) | The DSC primary access key |
| <a name="output_aa_dsc_secondary_access_key"></a> [aa\_dsc\_secondary\_access\_key](#output\_aa\_dsc\_secondary\_access\_key) | The DSC secondary access key |
| <a name="output_aa_dsc_server_endpoint"></a> [aa\_dsc\_server\_endpoint](#output\_aa\_dsc\_server\_endpoint) | The DSC server endpoint of the automation account |
| <a name="output_aa_id"></a> [aa\_id](#output\_aa\_id) | The ID of the automation account |
| <a name="output_aa_identity"></a> [aa\_identity](#output\_aa\_identity) | The identity block of the automation account |
| <a name="output_aa_name"></a> [aa\_name](#output\_aa\_name) | The name of the automation account |
| <a name="output_automation_module_ids"></a> [automation\_module\_ids](#output\_automation\_module\_ids) | List of IDs for the Automation Modules. |
| <a name="output_automation_python3_package_ids"></a> [automation\_python3\_package\_ids](#output\_automation\_python3\_package\_ids) | List of IDs for the Automation Python3 Packages. |
| <a name="output_automation_runbook_ids"></a> [automation\_runbook\_ids](#output\_automation\_runbook\_ids) | List of IDs for the Automation Runbooks. |
| <a name="output_automation_schedule_ids"></a> [automation\_schedule\_ids](#output\_automation\_schedule\_ids) | List of IDs for the Automation Schedules. |
