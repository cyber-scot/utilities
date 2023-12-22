param (
    [string]$RunTerraformInit = "true",
    [string]$RunTerraformPlan = "true",
    [string]$RunTerraformPlanDestroy = "false",
    [string]$RunTerraformApply = "false",
    [string]$RunTerraformDestroy = "false",
    [bool]$DebugMode = $false,
    [string]$DeletePlanFiles = "true",
    [string]$TerraformVersion = "latest",

    [Parameter(Mandatory = $true)]
    [string]$BackendStorageSubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$BackendStorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$LzName,

    [Parameter(Mandatory = $true)]
    [string]$StackName
)

try
{
    $ErrorActionPreference = 'Stop'
    $CurrentWorkingDirectory = (Get-Location).path

    # Enable debug mode if DebugMode is set to $true
    if ($DebugMode)
    {
        $DebugPreference = "Continue"
    }
    else
    {
        $DebugPreference = "SilentlyContinue"
    }

    # Function to check if Tfenv is installed
    function Test-TfenvExists
    {
        try
        {
            $tfenvPath = Get-Command tfenv -ErrorAction Stop
            Write-Host "[$( $MyInvocation.MyCommand.Name )] Success: Tfenv found at: $( $tfenvPath.Source )" -ForegroundColor Green
            return $true
        }
        catch
        {
            Write-Warning "[$( $MyInvocation.MyCommand.Name )] Warning: Tfenv is not installed or not in PATH. Skipping version checking."
            return $false
        }
    }

    # Function to check if Terraform is installed
    function Test-TerraformExists
    {
        try
        {
            $terraformPath = Get-Command terraform -ErrorAction Stop
            Write-Host "[$( $MyInvocation.MyCommand.Name )] Success: Terraform found at: $( $terraformPath.Source )" -ForegroundColor Green
        }
        catch
        {
            Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Terraform is not installed or not in PATH. Exiting."
            exit 1
        }
    }

    function Get-StackDirectory
    {
        param (
            [string]$StackName,
            [string]$CurrentWorkingDirectory
        )

        # Scan the 'stacks' directory and create a mapping
        $folderMap = @{ }
        $StacksFolderName = "stacks" # This shouldn't really ever change
        $StacksFullPath = Join-Path -Path $CurrentWorkingDirectory -ChildPath $StacksFolderName
        Set-Location $StacksFullPath
        Get-ChildItem -Path $StacksFullPath -Directory | ForEach-Object {
            $folderNumber = $_.Name.Split('_')[0]
            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Folder number is $folderNumber"
            $folderName = $_.Name.Split('_')[1]
            $folderMap[$folderName.ToLower()] = $_.Name
        }

        $targetFolder = $folderMap[$StackName.ToLower()]
        $CalculatedPath = Join-Path -Path $StacksFullPath -ChildPath $targetFolder
        Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: targetFolder is $targetFolder"
        if ($null -ne $targetFolder)
        {
            Write-Information "[$( $MyInvocation.MyCommand.Name )] Info: Changing to folder: $CalculatedPath"
            Set-Location $CalculatedPath
        }
        else
        {
            Write-Host "[$( $MyInvocation.MyCommand.Name )] Error: Invalid folder selection"
            exit 1
        }
    }

    function Get-GitBranch
    {
        try
        {
            # Get the current Git branch name
            $branchName = (git rev-parse --abbrev-ref HEAD).toLower()

            # Check if the command was successful
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branchName))
            {
                throw "Failed to get the current Git branch."
            }

            # Determine the workspace name based on the branch name
            $workspace = if ($branchName -eq "main" -or $branchName -eq "master")
            {
                "prd"
            }
            else
            {
                $branchName
            }

            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Git branch determined as: $workspace"
            return $workspace
        }
        catch
        {
            Write-Error "[$( $MyInvocation.MyCommand.Name )] Error encountered: $_"
            return $false
        }
    }

    function Select-TerraformWorkspace
    {
        param (
            [string]$Workspace
        )

        # Try to create a new workspace or select it if it already exists
        terraform workspace new $Workspace
        if ($LASTEXITCODE -eq 0)
        {
            Write-Host "[$( $MyInvocation.MyCommand.Name )] Success: Successfully created and selected the Terraform workspace '$Workspace'." -ForegroundColor Green
            return $Workspace
        }
        else
        {
            terraform workspace select $Workspace 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0)
            {
                Write-Host "[$( $MyInvocation.MyCommand.Name )] Success: Successfully selected the existing Terraform workspace '$Workspace'." -ForegroundColor Green
                return $Workspace
            }
            else
            {
                Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Failed to select the existing Terraform workspace '$Workspace'."
                return $false
            }
        }
    }

    function Invoke-TerraformInit
    {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [string]$BackendStorageSubscriptionId,

            [Parameter(Mandatory = $true)]
            [string]$BackendStorageAccountName,

            [Parameter(Mandatory = $true)]
            [string]$LzName,

            [Parameter(Mandatory = $true)]
            [string]$Workspace,

            [Parameter(Mandatory = $true)]
            [string]$WorkingDirectory
        )

        Begin
        {
            # Initial setup and variable declarations
            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Initializing Terraform..."
            $Env:TF_VAR_lz_name = $LzName.ToLower()
            $BackendStorageAccountBlobContainerName = "tfstate-$Workspace-$LzName-uksouth"
        }

        Process
        {
            try
            {
                # Change to the specified working directory
                Set-Location -Path $WorkingDirectory

                # Construct the backend config parameters
                $backendConfigParams = @(
                "-backend-config=subscription_id=$BackendStorageSubscriptionId",
                "-backend-config=storage_account_name=$BackendStorageAccountName",
                "-backend-config=container_name=$BackendStorageAccountBlobContainerName"
                )

                Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Backend config params are: $backendConfigParams"

                # Run terraform init with the constructed parameters
                terraform init @backendConfigParams | Out-Host
                Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Last exit code is $LASTEXITCODE"
                return $true
                # Check if terraform init was successful
                if ($LASTEXITCODE -ne 0)
                {
                    throw "Terraform init failed with exit code $LASTEXITCODE"
                }
            }
            catch
            {
                Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Terraform init failed with exception: $_"
                return $false
            }
        }

        End
        {
            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Terraform initialization completed."
        }
    }


    # Function to execute Terraform plan
    function Invoke-TerraformPlan
    {
        if ($RunTerraformPlan -eq $true)
        {
            Write-Host "[$( $MyInvocation.MyCommand.Name )] Info: Running Terraform Plan in $WorkingDirectory" -ForegroundColor Green
            terraform plan -out tfplan.plan | Out-Host
            if (Test-Path tfplan.plan)
            {
                terraform show -json tfplan.plan | Tee-Object -FilePath tfplan.json | Out-Null
                return $true
            }
            else
            {
                Write-Host "[$( $MyInvocation.MyCommand.Name )] Error: Terraform plan file not created"
                return $false
            }
        }
    }

    # Function to execute Terraform plan for destroy
    function Invoke-TerraformPlanDestroy
    {
        if ($RunTerraformPlanDestroy -eq $true)
        {
            try
            {
                Write-Host "[$( $MyInvocation.MyCommand.Name )] Info: Running Terraform Plan Destroy in $WorkingDirectory" -ForegroundColor Yellow
                terraform plan -destroy -out tfplan.plan | Out-Host
                if (Test-Path tfplan.plan)
                {
                    terraform show -json tfplan.plan | Tee-Object -FilePath tfplan.json | Out-Null
                    return $true
                }
                else
                {
                    Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Terraform plan file not created"
                    return $false
                }
            }
            catch
            {
                Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Terraform Plan Destroy failed"
                return $false
            }
        }
        return $false
    }


    # Function to execute Terraform apply
    function Invoke-TerraformApply
    {
        if ($RunTerraformApply -eq $true)
        {
            try
            {
                Write-Host "[$( $MyInvocation.MyCommand.Name )] Info: Running Terraform Apply in $WorkingDirectory" -ForegroundColor Yellow
                if (Test-Path tfplan.plan)
                {
                    terraform apply -auto-approve tfplan.plan | Out-Host
                }
                else
                {
                    throw "[$( $MyInvocation.MyCommand.Name )] Error: Terraform plan file not present for terraform apply"
                    return $false
                }
            }
            catch
            {
                throw "[$( $MyInvocation.MyCommand.Name )] Error: Terraform Apply failed"
                return $false
            }
        }
    }

    # Function to execute Terraform destroy
    function Invoke-TerraformDestroy
    {
        if ($RunTerraformDestroy -eq $true)
        {
            try
            {
                Write-Host "[$( $MyInvocation.MyCommand.Name )] Info: Running Terraform Destroy in $WorkingDirectory" -ForegroundColor Yellow
                if (Test-Path tfplan.plan)
                {
                    terraform apply -auto-approve tfplan.plan | Out-Host
                }
                else
                {
                    throw "[$( $MyInvocation.MyCommand.Name )] Error: Terraform plan file not present for terraform destroy"
                    return $false
                }
            }
            catch
            {
                throw "[$( $MyInvocation.MyCommand.Name )] Error: Terraform Destroy failed"
                return $false
            }
        }
    }

    Test-TfenvExists
    Test-TerraformExists

    # Convert string parameters to boolean
    $RunTerraformInit = [System.Convert]::ToBoolean($RunTerraformInit)
    $RunTerraformPlan = [System.Convert]::ToBoolean($RunTerraformPlan)
    $RunTerraformPlanDestroy = [System.Convert]::ToBoolean($RunTerraformPlanDestroy)
    $RunTerraformApply = [System.Convert]::ToBoolean($RunTerraformApply)
    $RunTerraformDestroy = [System.Convert]::ToBoolean($RunTerraformDestroy)
    $DeletePlanFiles = [System.Convert]::ToBoolean($DeletePlanFiles)


    # Diagnostic output
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: LzName: $LzName"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: RunTerraformInit: $RunTerraformInit"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: RunTerraformPlan: $RunTerraformPlan"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: RunTerraformPlanDestroy: $RunTerraformPlanDestroy"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: RunTerraformApply: $RunTerraformApply"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: RunTerraformDestroy: $RunTerraformDestroy"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: DebugMode: $DebugMode"
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: DeletePlanFiles: $DeletePlanFiles"

    if ($RunTerraformPlan -eq $true -and $RunTerraformPlanDestroy -eq $true)
    {
        Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Both Terraform Plan and Terraform Plan Destroy cannot be true at the same time"
        exit 1
    }

    if ($RunTerraformApply -eq $true -and $RunTerraformDestroy -eq $true)
    {
        Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: Both Terraform Apply and Terraform Destroy cannot be true at the same time"
        exit 1
    }

    if ($RunTerraformPlan -eq $false -and $RunTerraformApply -eq $true)
    {
        Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: You must run terraform plan and terraform apply together to use this script"
        exit 1
    }

    if ($RunTerraformPlanDestroy -eq $false -and $RunTerraformDestroy -eq $true)
    {
        Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: You must run terraform plan destroy and terraform destroy together to use this script"
        exit 1
    }


    # Change to the specified working directory
    try
    {
        Get-StackDirectory -StackName $StackName -CurrentWorkingDirectory $CurrentWorkingDirectory
        $WorkingDirectory = (Get-Location).Path
    }
    catch
    {
        throw "[$( $MyInvocation.MyCommand.Name )] Error: Unable to change to directory."
        exit 1
    }


    $Workspace = Get-GitBranch
    Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Workspace from Get-GitBranch is $Workspace"

    # Execution flow
    if (
    Invoke-TerraformInit `
    -WorkingDirectory $WorkingDirectory `
    -BackendStorageAccountName $BackendStorageAccountName `
    -BackendStorageSubscriptionId $BackendStorageSubscriptionId `
    -Workspace $Workspace `
    -LzName $LzName
    )
    {
        if (Select-TerraformWorkspace -Workspace $Workspace)
        {

            try
            {
                if (Invoke-TerraformPlan)
                {
                    $planSuccess = $true
                }
            }
            catch
            {
                throw "[$( $MyInvocation.MyCommand.Name )] Error: Error running terraform plan"
            }

            try
            {

                if (Invoke-TerraformPlanDestroy)
                {
                    $planDestroySuccess = $true
                }
            }
            catch
            {
                throw "[$( $MyInvocation.MyCommand.Name )] Error: Error running terraform plan destroy"
            }

            if ($planSuccess -and $RunTerraformApply -eq $true)
            {
                try
                {
                    Invoke-TerraformApply
                }
                catch
                {
                    throw "[$( $MyInvocation.MyCommand.Name )] Error: Error running terraform apply"
                }
            }
            if ($planDestroySuccess -and $RunTerraformDestroy -eq $true)
            {
                try
                {
                    Invoke-TerraformDestroy
                }
                catch
                {
                    throw "[$( $MyInvocation.MyCommand.Name )] Error: Error running terraform destroy"
                }
            }
        }

        else
        {
            Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: There has been a problem wihin the selection of the terraform workspace"
            exit 1
        }
    }
    else
    {
        Write-Error "[$( $MyInvocation.MyCommand.Name )] Error: There has been a problem wihin the terraform init step"
        exit 1
    }

}
catch
{
    throw "[$( $MyInvocation.MyCommand.Name )] Error: An error has occured in the script:  $_"
}

finally
{
    if ($DeletePlanFiles -eq $true)
    {
        $planFile = "tfplan.plan"
        if (Test-Path $planFile)
        {
            Remove-Item -Path $planFile -Force -ErrorAction Stop
            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Deleted $planFile"
        }
        $planJson = "tfplan.json"
        if (Test-Path $planJson)
        {
            Remove-Item -Path $planJson -Force -ErrorAction Stop
            Write-Debug "[$( $MyInvocation.MyCommand.Name )] Debug: Deleted $planJson"
        }
    }
    Set-Location $CurrentWorkingDirectory
}
