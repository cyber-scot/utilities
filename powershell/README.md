# Packer Script Execution Guide

This guide provides instructions on setting up environment variables and running the `Run-Packer.ps1` PowerShell script for Packer operations.

## Setting Environment Variables

Environment variables are used to pass configuration options and settings to the PowerShell script. These variables can be set both locally (for the current PowerShell session) and system-wide.

### Prerequisites

- Administrative privileges are required to set system environment variables.
- PowerShell must be run as an administrator to execute these scripts.

### Populate Environment Variables for local env - Populate-LocalVars.ps1

Run this PowerShell script to set the required environment variables.

You can run this script in a limited configuration, for example:

```powershell
# PowerShell script to set user-level environment variables with predefined values for Linux
# Define a hashtable with key-value pairs for environment variables
$predefinedVariableValues = @{
    "WORKING_DIRECTORY" = "example_working_directory"
    "RUN_PACKER_BUILD" = "true"
    "RUN_PACKER_VALIDATE" = "true"
    "RUN_PACKER_INIT" = "true"
    "ENABLE_DEBUG_MODE" = "true"
    "PACKER_VERSION" = "latest"
    "PKR_VAR_registry_username" = "example"
    "PKR_VAR_registry_password" = "example"
}

# Set each predefined variable
foreach ($varName in $predefinedVariableValues.Keys) {
    $value = $predefinedVariableValues[$varName]

    if ($isLinux) {
        # Ensure the PowerShell profile directory exists
        $profileDirectory = [System.IO.Path]::GetDirectoryName($PROFILE)
        if (-not (Test-Path $profileDirectory)) {
            New-Item -ItemType Directory -Path $profileDirectory -Force
        }

        # Ensure the PowerShell profile file exists
        if (-not (Test-Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
        }

        # Append to PowerShell profile and set in current session
        $exportCommand = "`n`$Env:$varName = `"$value`""
        Add-Content -Path $PROFILE -Value $exportCommand
        Set-Variable -Name $varName -Value $value -Scope Global
    }
    elseif ($IsMacOS)
    {
        # Ensure the PowerShell profile directory exists
        $profileDirectory = [System.IO.Path]::GetDirectoryName($PROFILE)
        if (-not (Test-Path $profileDirectory)) {
            New-Item -ItemType Directory -Path $profileDirectory -Force
        }

        # Ensure the PowerShell profile file exists
        if (-not (Test-Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
        }

        # Append to PowerShell profile and set in current session
        $exportCommand = "`n`$Env:$varName = `"$value`""
        Add-Content -Path $PROFILE -Value $exportCommand
        Set-Variable -Name $varName -Value $value -Scope Global
    }
    else {
        # On other systems, set user environment variable
        [System.Environment]::SetEnvironmentVariable($varName, $value, [System.EnvironmentVariableTarget]::User)
    }
}

Write-Host "User-level environment variables have been set."
Write-Host "Please close your powershell window and reopen to refresh environment" -ForegroundColor Yellow
```
## Running the Script

To run the Run-Packer.ps1 script with the environment variables, use the following command in PowerShell:

```powershell
.\Run-Packer.ps1 `
-WorkingDirectory "foo/bar" `
-RunPackerInit "true" `
-RunPackerValidate "true"`
-RunPackerBuild "true" `
-DebugMode "true" `
-PackerVersion "latest"`
-PackerFileName "packer.pkr.hcl `
```

### Post-Execution

- After running the script, the Packer operations as specified by the parameters will be executed.
- Remember that changes to system environment variables might require a system restart to be recognized by all applications.


___

# Terraform Script Execution Guide

This guide provides instructions on setting up environment variables and running the `Run-Terraform.ps1` PowerShell script for Terraform operations.

## Setting Environment Variables

Environment variables are used to pass configuration options and settings to the PowerShell script. These variables can be set both locally (for the current PowerShell session) and system-wide.

### Prerequisites

- Administrative privileges are required to set system environment variables.
- PowerShell must be run as an administrator to execute these scripts.

### Populate Environment Variables for local env - Populate-LocalVars.ps1

Run this PowerShell script to set the required environment variables.

You can run this script in a limited configuration, for example:

```powershell
# PowerShell script to set user-level environment variables with predefined values for Linux
# Define a hashtable with key-value pairs for environment variables
$predefinedVariableValues = @{
    "BACKEND_STORAGE_SUBSCRIPTION_ID" = "example_subscription_id"
    "BACKEND_STORAGE_USES_AZURE_AD" = "true"
    "BACKEND_STORAGE_RESOURCE_GROUP_NAME" = "example_resource_group_name"
    "BACKEND_STORAGE_ACCOUNT_NAME" = "example_account_name"
    "BACKEND_STORAGE_ACCOUNT_BLOB_CONTAINER_NAME" = "example_blob_container_name"
    "ARM_CLIENT_ID" = "example"
    "ARM_CLIENT_SECRET" = "example"
    "ARM_SUBSCRIPTION_ID" = "example"
    "ARM_TENANT_ID" = "example"
    "ARM_USE_AZUREAD" = "example"
}

# Set each predefined variable
foreach ($varName in $predefinedVariableValues.Keys) {
    $value = $predefinedVariableValues[$varName]

    if ($isLinux) {
        # Ensure the PowerShell profile directory exists
        $profileDirectory = [System.IO.Path]::GetDirectoryName($PROFILE)
        if (-not (Test-Path $profileDirectory)) {
            New-Item -ItemType Directory -Path $profileDirectory -Force
        }

        # Ensure the PowerShell profile file exists
        if (-not (Test-Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
        }

        # Append to PowerShell profile and set in current session
        $exportCommand = "`n`$Env:$varName = `"$value`""
        Add-Content -Path $PROFILE -Value $exportCommand
        Set-Variable -Name $varName -Value $value -Scope Global
    }
    elseif ($IsMacOS)
    {
        # Ensure the PowerShell profile directory exists
        $profileDirectory = [System.IO.Path]::GetDirectoryName($PROFILE)
        if (-not (Test-Path $profileDirectory)) {
            New-Item -ItemType Directory -Path $profileDirectory -Force
        }

        # Ensure the PowerShell profile file exists
        if (-not (Test-Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force
        }

        # Append to PowerShell profile and set in current session
        $exportCommand = "`n`$Env:$varName = `"$value`""
        Add-Content -Path $PROFILE -Value $exportCommand
        Set-Variable -Name $varName -Value $value -Scope Global
    }
    else {
        # On other systems, set user environment variable
        [System.Environment]::SetEnvironmentVariable($varName, $value, [System.EnvironmentVariableTarget]::User)
    }
}

Write-Host "User-level environment variables have been set."
Write-Host "Please close your powershell window and reopen to refresh environment" -ForegroundColor Yellow

```
## Running the Script

To run the Run-Terraform.ps1 script with the environment variables, use the following command in PowerShell:

```powershell
.\Run-Terraform.ps1 `
  -WorkingDirectory $Env:WORKING_DIRECTORY `
  -RunTerraformInit $Env:RUN_TERRAFORM_INIT `
  -RunTerraformPlan $Env:RUN_TERRAFORM_PLAN `
  -RunTerraformPlanDestroy $Env:RUN_TERRAFORM_PLAN_DESTROY `
  -RunTerraformApply $Env:RUN_TERRAFORM_APPLY `
  -RunTerraformDestroy $Env:RUN_TERRAFORM_DESTROY `
  -DebugMode $Env:ENABLE_DEBUG_MODE `
  -DeletePlanFiles $Env:DELETE_PLAN_FILES `
  -TerraformVersion $Env:TERRAFORM_VERSION `
  -BackendStorageSubscriptionId $Env:BACKEND_STORAGE_SUBSCRIPTION_ID `
  -BackendStorageUsesAzureAD $Env:BACKEND_STORAGE_USES_AZURE_AD `
  -BackendStorageResourceGroupName $Env:BACKEND_STORAGE_RESOURCE_GROUP_NAME `
  -BackendStorageAccountName $Env:BACKEND_STORAGE_ACCOUNT_NAME `
  -BackendStorageAccountBlobContainerName $Env:BACKEND_STORAGE_ACCOUNT_BLOB_CONTAINER_NAME `
  -TerraformStateName $Env:TERRAFORM_STATE_NAME
```

Alternatively, you can just hard code the values you want:

```powershell
.\Run-Terraform.ps1 `
  -RunTerraformInit true `
  -RunTerraformPlan true `
  -BackendStorageSubscriptionId "foo" `
  -BackendStorageResourceGroupName "bar" `
  -BackendStorageAccountName "example" `
  -BackendStorageAccountBlobContainerName "icecream" `
  -TerraformStateName "example.terraform.tfstate"
```

Or a mixture

```powershell
.\Run-Terraform.ps1 `
  -RunTerraformInit true `
  -RunTerraformPlan true `
  -BackendStorageSubscriptionId $Env:BACKEND_STORAGE_SUBSCRIPTION_ID `
  -BackendStorageResourceGroupName $Env:BACKEND_STORAGE_RESOURCE_GROUP_NAME `
  -BackendStorageAccountName $Env:BACKEND_STORAGE_ACCOUNT_NAME `
  -BackendStorageAccountBlobContainerName $Env:BACKEND_STORAGE_ACCOUNT_BLOB_CONTAINER_NAME `
  -TerraformStateName "cscot-dev.terraform.tfstate"
```

### Post-Execution

- After running the script, the Terraform operations as specified by the parameters will be executed.
- Remember that changes to system environment variables might require a system restart to be recognized by all applications.



```hcl
module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-build"
  location = local.location
  tags     = local.tags
}
```
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rg"></a> [rg](#module\_rg) | registry.terraform.io/libre-devops/rg/azurerm | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | The env variable, for example - prd for production. normally passed via TF\_VAR. | `string` | `"dev"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The loc variable, for the shorthand location, e.g. uks for UK South.  Normally passed via TF\_VAR. | `string` | `"uks"` | no |
| <a name="input_short"></a> [short](#input\_short) | The shorthand name of to be used in the build, e.g. cscot for CyberScot.  Normally passed via TF\_VAR. | `string` | `"ldo"` | no |
| <a name="input_static_tags"></a> [static\_tags](#input\_static\_tags) | The tags variable | `map(string)` | <pre>{<br>  "Contact": "info@cyber.scot",<br>  "CostCentre": "671888",<br>  "ManagedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name) | The mame for the resource group |

___
