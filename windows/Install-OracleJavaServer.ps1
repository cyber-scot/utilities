param(
    [string]$jrePath = (Join-Path (Get-Location) "server-jre-8u202-windows-x64.tar.gz"),
    [string]$installLocation = "C:\Program Files"
)

# Start the transcript
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Start-Transcript -Path "C:\transcript_$timestamp.log"

Write-Host "Script Parameters: JRE Path - $jrePath | Install Location - $installLocation"

# Validate the install location
if (-not (Test-Path $installLocation)) {
    New-Item -Path $installLocation -ItemType Directory
    Write-Host "Install location validated: $installLocation"
}

try {
    # Check if 7-zip is installed
    if (-not (Test-Path "C:\Program Files\7-Zip\7z.exe")) {
        Write-Host "Installing 7-Zip..."
        $installerPath = (Join-Path $env:TEMP "7z2301-x64.msi")
        Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2301-x64.msi" -OutFile $installerPath
        Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i $installerPath /qn"
        Remove-Item $installerPath -Force
    } else {
        Write-Host "7-Zip already installed."
    }

    # Decompress the .tar.gz file using 7-Zip
    Write-Host "Decompressing $jrePath using 7-Zip to $installLocation..."
    & "C:\Program Files\7-Zip\7z.exe" e -y -o$installLocation $jrePath
    Write-Host "Decompression completed."

    # Get the .tar filename from the original .tar.gz filename
    $tarFile = $jrePath -replace ".gz$", ""

    # Extract the .tar file using 7-Zip
    Write-Host "Extracting $tarFile using 7-Zip to $installLocation..."
    & "C:\Program Files\7-Zip\7z.exe" x -y -o$installLocation $tarFile
    Write-Host "Extraction completed."

    # Check the directories after extraction for more insight
    $directories = Get-ChildItem -Path $installLocation -Directory
    Write-Host "Directories found after extraction:"
    $directories.FullName

    # Find the JDK directory
    $jdkPath = $directories | Where-Object { $_.Name -eq "Java" } | Get-ChildItem -Directory | Where-Object { $_.Name -like "jdk*" } | Select-Object -First 1


    if ($null -ne $jdkPath) {
        # Setting JAVA_HOME for current session
        $env:JAVA_HOME = $jdkPath.FullName

        # Adding JDK bin directory to PATH for current session
        $env:Path += ";$($jdkPath.FullName)\bin"

        Write-Host "JAVA_HOME set to $($jdkPath.FullName) for current session."
        Write-Host "Added JDK bin directory to system PATH for current session."

        # Persisting JAVA_HOME and updated PATH for future sessions (Optional, but recommended)
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath.FullName, [System.EnvironmentVariableTarget]::Machine)
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$($jdkPath.FullName)\bin", [System.EnvironmentVariableTarget]::Machine)

        Write-Host "JAVA_HOME and PATH have been updated system-wide."
    } else {
        Write-Error "Could not find the JDK directory. Make sure the tarball has the standard JDK directory structure."
    }
} catch {
    Write-Error "Error encountered: $($_.Exception.Message)"
} finally {
    # Stop the transcript
    Stop-Transcript
    Write-Host "Script execution completed. Check the transcript for detailed logs."
}
