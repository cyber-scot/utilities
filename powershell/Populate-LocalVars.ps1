# PowerShell script to set user-level environment variables with predefined values for Linux
# Define a hashtable with key-value pairs for environment variables
$predefinedVariableValues = @{
    "WORKING_DIRECTORY" = "example_working_directory"
    "RUN_TERRAFORM_INIT" = "true"
    "RUN_TERRAFORM_PLAN" = "true"
    "RUN_TERRAFORM_PLAN_DESTROY" = "false"
    "RUN_TERRAFORM_APPLY" = "false"
    "RUN_TERRAFORM_DESTROY" = "false"
    "ENABLE_DEBUG_MODE" = "true"
    "DELETE_PLAN_FILES" = "true"
    "TERRAFORM_VERSION" = "latest"
    "BACKEND_STORAGE_SUBSCRIPTION_ID" = "example_subscription_id"
    "BACKEND_STORAGE_RESOURCE_GROUP_NAME" = "example_resource_group_name"
    "BACKEND_STORAGE_ACCOUNT_NAME" = "example_account_name"
    "BACKEND_STORAGE_ACCOUNT_BLOB_CONTAINER_NAME" = "example_blob_container_name"
    "TERRAFORM_STATE_NAME" = "example_state_name"
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
