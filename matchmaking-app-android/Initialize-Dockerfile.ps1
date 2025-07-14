<#
.SYNOPSIS
  Checks if a Dockerfile exists in the current folder. If missing, creates a minimal working Dockerfile.
  Also verifies Docker CLI and daemon connectivity.
.PARAMETER AutoCreate
  If set, will create the Dockerfile without prompting.
.EXAMPLE
  .\Initialize-Dockerfile.ps1
#>

param(
    [switch]$AutoCreate
)

$log = @()
function Log {
    param([string]$message)
    Write-Host $message
    $log += $message
}

function Save-Log {
    $log | Out-File -Encoding utf8 -FilePath (Join-Path $PWD "docker-initialize-log.txt")
}

Log "------------------------------------------------------------"
Log "✅ Dockerfile Initializer Script"
Log "------------------------------------------------------------"
Log "🕒 Timestamp: $(Get-Date)"
Log "📂 Working Directory: $PWD"

# 1️⃣ Check Docker CLI
try {
    $dockerVersion = docker --version
    Log "✔️ Docker CLI found: $dockerVersion"
} catch {
    Log "❌ Docker is not installed or not in PATH."
    Save-Log
    exit 1
}

# 2️⃣ Check Docker Daemon connectivity
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect") {
        Log "⚠️ Docker daemon not reachable. Make sure Docker Desktop is running."
    } else {
        Log "✔️ Docker daemon is responding."
    }
} catch {
    Log "⚠️ Could not run 'docker info'. Docker daemon might not be running."
}

# 3️⃣ Check for existing Dockerfile
$dockerfilePath = Join-Path $PWD "Dockerfile"

if (Test-Path $dockerfilePath) {
    Log "✅ Dockerfile already exists: $dockerfilePath"
    Save-Log
    exit 0
}

Log "⚠️ No Dockerfile found in this directory."

# 4️⃣ Decide what to do
if ($AutoCreate) {
    Log "➡️ AutoCreate flag is set. Creating minimal Dockerfile automatically..."
} else {
    $choice = Read-Host "❓ No Dockerfile found. Do you want to create a minimal one now? (Y/N)"
    if ($choice -notin @('Y','y')) {
        Log "❌ User chose not to create a Dockerfile. Exiting."
        Save-Log
        exit 0
    }
}

# 5️⃣ Create minimal Dockerfile
$dockerfileContent = @"
# 🐳 Minimal Dockerfile
FROM alpine:latest
CMD ["echo", "Hello from your new Dockerfile!"]
"@

$dockerfileContent | Out-File -Encoding utf8 -FilePath $dockerfilePath

Log "✅ Created minimal Dockerfile at: $dockerfilePath"
Log "➡️ Content:"
Log "-----------------------------------"
Log $dockerfileContent
Log "-----------------------------------"

# 6️⃣ Final message
Log "✅ Done! You can now run:"
Log "   docker build -t myimage ."

Save-Log
