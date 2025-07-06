<#
.SYNOPSIS
    Diagnoses Docker environment and docker-compose issues in a given project folder.
.DESCRIPTION
    - Checks if Docker is installed
    - Checks if Docker daemon is running
    - Checks if docker-compose is installed
    - Validates docker-compose.yml in the project
    - Logs results
.PARAMETER ProjectPath
    The path to the project containing docker-compose.yml
.EXAMPLE
    .\Check-DockerStatus.ps1 -ProjectPath "E:\VedicMatchMaking"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$LogFile = Join-Path $ProjectPath "docker-diagnostics.log"
"📝 Docker Diagnostics Log" | Out-File $LogFile
"Timestamp: $(Get-Date)" | Out-File $LogFile -Append
"Project Path: $ProjectPath" | Out-File $LogFile -Append
"-------------------------------------------" | Out-File $LogFile -Append

function Log {
    param([string]$Message)
    Write-Host $Message
    $Message | Out-File $LogFile -Append
}

Log "`n✅ Checking Docker installation..."
try {
    $dockerVersion = docker --version
    Log "✔️ Docker found: $dockerVersion"
} catch {
    Log "❌ Docker is NOT installed or not in PATH."
    exit 1
}

Log "`n✅ Checking Docker daemon status..."
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect" -or $dockerInfo -match "Cannot connect") {
        Log "❌ Docker daemon is NOT running!"
        Log "$dockerInfo"
    } else {
        Log "✔️ Docker daemon is running."
        Log "$dockerInfo"
    }
} catch {
    Log "❌ Error running 'docker info'. Docker may not be running."
    exit 1
}

Log "`n✅ Checking Docker Compose installation..."
try {
    $composeVersion = docker-compose --version
    Log "✔️ docker-compose found: $composeVersion"
} catch {
    Log "❌ docker-compose is NOT installed or not in PATH."
    exit 1
}

$ComposeFile = Join-Path $ProjectPath "docker-compose.yml"
if (!(Test-Path $ComposeFile)) {
    Log "❌ docker-compose.yml not found in $ProjectPath"
    exit 1
}

Log "`n✅ Validating docker-compose.yml..."
try {
    Set-Location $ProjectPath
    $composeConfig = docker-compose config 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log "❌ docker-compose config found ERRORS:"
        Log "$composeConfig"
    } else {
        Log "✔️ docker-compose.yml is valid:"
        Log "$composeConfig"
    }
} catch {
    Log "❌ Error validating docker-compose.yml"
}

Log "`n✅ Diagnostics complete! See log file at: $LogFile"
