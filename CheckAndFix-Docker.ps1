<#
.SYNOPSIS
    Diagnoses and suggests fixes for Docker and docker-compose issues in a project.
.PARAMETER ProjectPath
    Path to your project folder.
.EXAMPLE
    .\CheckAndFix-Docker.ps1 -ProjectPath "E:\VedicMatchMaking"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$LogFile = Join-Path $ProjectPath "docker-diagnostics.log"

function Log {
    param([string]$Message)
    Write-Host $Message
    $Message | Out-File $LogFile -Append
}

function Section {
    param([string]$Title)
    $border = "-" * 60
    Log "`n$border"
    Log "✅ $Title"
    Log "$border"
}

# Start logging
"📝 Docker Diagnostics Log" | Out-File $LogFile
"Timestamp: $(Get-Date)" | Out-File $LogFile -Append
"Project Path: $ProjectPath" | Out-File $LogFile -Append

# 1️⃣ Check Docker installation
Section "Checking Docker installation"
try {
    $dockerVersion = docker --version
    Log "✔️ Docker CLI found: $dockerVersion"
} catch {
    Log "❌ Docker is NOT installed or not in PATH."
    Log "➡️ Install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# 2️⃣ Check Docker daemon
Section "Checking Docker daemon status"
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect" -or $dockerInfo -match "Cannot connect") {
        Log "❌ Docker daemon is NOT running!"
        Log "➡️ How to fix:"
        Log "   - Start Docker Desktop manually (search in Start Menu)"
        Log "   - Or run in Admin PowerShell: Start-Service com.docker.service"
        Log "   - Or right-click Docker icon in tray and choose 'Restart Docker Desktop'"
        Log "❗ Raw error:"
        Log $dockerInfo
        exit 1
    } else {
        Log "✔️ Docker daemon is running."
        Log $dockerInfo
    }
} catch {
    Log "❌ Error running 'docker info'."
    Log $_
    exit 1
}

# 3️⃣ Check docker-compose installation
Section "Checking Docker Compose installation"
try {
    $composeVersion = docker-compose --version
    Log "✔️ docker-compose found: $composeVersion"
} catch {
    Log "❌ docker-compose is NOT installed or not in PATH."
    Log "➡️ Install it via Docker Desktop or CLI plugin."
    exit 1
}

# 4️⃣ Check if docker-compose.yml exists
Section "Checking for docker-compose.yml"
$ComposeFile = Join-Path $ProjectPath "docker-compose.yml"
if (!(Test-Path $ComposeFile)) {
    Log "❌ docker-compose.yml not found in $ProjectPath"
    exit 1
} else {
    Log "✔️ Found docker-compose.yml at $ComposeFile"
}

# 5️⃣ Validate docker-compose config
Section "Validating docker-compose.yml"
Set-Location $ProjectPath
$composeConfig = docker-compose config 2>&1
if ($LASTEXITCODE -ne 0) {
    Log "❌ docker-compose config found ERRORS:"
    Log $composeConfig

    # Optional: Look for duplicate keys specifically
    Section "Scanning for duplicate keys in docker-compose.yml"
    $lines = Get-Content $ComposeFile
    $keyTracker = @{}
    $duplicates = @()

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i].Trim()
        if ($line -match "^([a-zA-Z0-9_-]+):") {
            $key = $matches[1]
            if ($keyTracker.ContainsKey($key)) {
                $duplicates += "Line $($i + 1): Duplicate key '$key' (previous at line $($keyTracker[$key] + 1))"
            } else {
                $keyTracker[$key] = $i
            }
        }
    }

    if ($duplicates.Count -eq 0) {
        Log "✅ No obvious duplicate keys detected in docker-compose.yml."
    } else {
        Log "❗ Duplicate keys detected:"
        $duplicates | ForEach-Object { Log $_ }
        Log "`n➡️ Suggestion: Open your docker-compose.yml around these lines and remove duplicate keys."
    }

    Log "`n❗ Please fix the errors above and rerun this script."
} else {
    Log "✔️ docker-compose.yml is valid:"
    Log $composeConfig
}

Section "Diagnostics complete!"
Log "📃 See detailed log at: $LogFile"
