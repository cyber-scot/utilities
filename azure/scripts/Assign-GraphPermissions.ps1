#!/usr/bin/env pwsh
# To use this script you need various permissions

$DestinationTenantId = $Env:ARM_TENANT_ID
$MsiName = "id-cscot-uks-prd-mgmt-01" # Name of system-assigned or user-assigned managed service identity. (System-assigned use same name as resource).

$oPermissions = @(
"Application.ReadWrite.All"
"Group.ReadWrite.All"
"AppRoleAssignment.ReadWrite.All"
"Directory.ReadWrite.All"
"RoleManagement.ReadWrite.Directory"
)

$ClientId = $Env:ARM_CLIENT_ID
$ClientSecret = $Env:ARM_CLIENT_SECRET

# Define the resource (Microsoft Graph)
$resource = "https://graph.microsoft.com"

# Define the Azure AD authorization endpoint
$authUrl = "https://login.microsoftonline.com/$DestinationTenantId/oauth2/token"

# Define the body of the POST request
$body = @{
    "resource" = $resource
    "client_id" = $ClientId
    "client_secret" = $ClientSecret
    "grant_type" = "client_credentials"
}

# Execute the POST request to get the access token
$tokenResponse = Invoke-RestMethod -Method Post -Uri $authUrl -Body $body

# Extract the access token
$accessToken = $tokenResponse.access_token

$SecuredPasswordPassword = ConvertTo-SecureString `
-String $ClientSecret -AsPlainText -Force

$ClientSecretCredential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $ClientId, $SecuredPasswordPassword

$SecuredAccessToken = $SecuredPasswordPassword = ConvertTo-SecureString `
-String $accessToken -AsPlainText -Force

$GraphAppId = "00000003-0000-0000-c000-000000000000" # Don't change this.

$oMsi = Get-AzADServicePrincipal -Filter "displayName eq '$MsiName'"
$oGraphSpn = Get-AzADServicePrincipal -Filter "appId eq '$GraphAppId'"

$oAppRole = $oGraphSpn.AppRole | Where-Object {($_.Value -in $oPermissions) -and ($_.AllowedMemberType -contains "Application")}

Connect-MgGraph -AccessToken $SecuredAccessToken

foreach($AppRole in $oAppRole)
{
    $oAppRoleAssignment = @{
        "PrincipalId" = $oMSI.Id
        "ResourceId" = $oGraphSpn.Id
        "AppRoleId" = $AppRole.Id
    }

    New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $oAppRoleAssignment.PrincipalId `
    -BodyParameter $oAppRoleAssignment `
    -Verbose
}
