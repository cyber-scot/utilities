<#
.SYNOPSIS
This script creates AD users based on a provided list of usernames.

.DESCRIPTION
The script will create users in the specified organizational unit (OU) within Active Directory.

.PARAMETER Password
The password that will be set for each created user.

.PARAMETER DomainName
The name of your domain (e.g., "example" for "example.com").

.PARAMETER DomainTLD
The top-level domain (e.g., "com" for "example.com").

.PARAMETER Usernames
An array of usernames for the accounts to be created.

.PARAMETER OrganizationalUnit
The distinguished name of the organizational unit where the users should be created.

.EXAMPLE
.\CreateUsers.ps1 -Password "P@ssw0rd" -DomainName "example" -DomainTLD "com" -OrganizationalUnit "OU=ServiceAccounts,DC=example,DC=com"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$DomainTLD,

    [Parameter(Mandatory=$false)]
    [string[]]$Usernames = @("User1", "User2", "User3"),

    [Parameter(Mandatory=$true)]
    [string]$OrganizationalUnit
)

# Verify OU existence
try {
    $ou = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OrganizationalUnit'" -ErrorAction Stop
    if (-not $ou) {
        Write-Host "OU does not exist. Exiting."
        exit
    }
} catch {
    Write-Host "Error checking OU: $_"
    exit
}

# Generate a unique log filename using the current date and time
$logFilename = "C:\UserCreationLog_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log"

# Start a transcript log
Start-Transcript -Path $logFilename -Append

foreach ($username in $Usernames) {
    try {
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction Stop
        if ($existingUser) {
            Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $username already exists."
        } else {
            New-ADUser `
                -SamAccountName $username `
                -UserPrincipalName "$username@$DomainName.$DomainTLD" `
                -Name $username `
                -GivenName $username `
                -Surname $username `
                -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
                -CannotChangePassword $true `
                -PasswordNeverExpires $true `
                -Path $OrganizationalUnit `
                -Enabled $true
            Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - User $username created successfully."
        }
    } catch {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Failed to create $username. Error: $_"
    }
}

# End transcript logging
Stop-Transcript
