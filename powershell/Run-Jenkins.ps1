param (
    [string]$ImageName = "ghcr.io/cyber-scot/base-images/jenkins-alpine-cicd-base:latest",
    [string]$ContainerName = "jenkins",
    [int]$ExternalWebPort = 8080,
    [int]$InternalWebPort = 8080,
    [int]$ExternalAgentPort = 50000,
    [int]$InternalAgentPort = 50000,
    [string]$VolumeMapping = "jenkins_home:/var/jenkins_home",
    [string]$PrimaryDNS = "8.8.8.8", # Default to Google's public DNS
    [string]$SecondaryDNS = "8.8.4.4" # Default to Google's secondary public DNS
)

# Pull the latest Jenkins Docker image
docker pull $ImageName

# Run the Jenkins container with specified parameters
$ContainerId = $(docker run -d `
-p "${ExternalWebPort}:${InternalWebPort}" `
-p "${ExternalAgentPort}:${InternalAgentPort}" `
--name $ContainerName `
--volume $VolumeMapping `
--dns $PrimaryDNS `
--dns $SecondaryDNS `
--privileged `
$ImageName)

Write-Host "Success: The container ID is: ${ContainerId}" -ForegroundColor Green

# Wait for 7 seconds
Start-Sleep -Seconds 7

# Retrieve the initial Admin Password
$JenkinsTempPassword = $(docker exec $ContainerName cat /var/jenkins_home/secrets/initialAdminPassword)
Write-Host "Success: Jenkins temp password is ${JenkinsTempPassword}" -ForegroundColor Green
