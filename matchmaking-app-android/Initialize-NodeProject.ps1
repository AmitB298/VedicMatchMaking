<#
.SYNOPSIS
  Production-grade Node.js Docker initializer.
.DESCRIPTION
  Ensures package.json, package-lock.json, and server.js exist. Can auto-generate server.js if missing.
.PARAMETER Force
  Overwrites existing server.js if present.
.EXAMPLE
  .\Initialize-NodeProject.ps1
#>

param(
    [switch]$Force
)

$LogFile = Join-Path $PWD "node-project-initialize-log.txt"
$Log = @()

function Log {
    param([string]$Message)
    Write-Host $Message
    $Log += $Message
}

function Save-Log {
    $Log | Out-File -Encoding utf8 -FilePath $LogFile
}

Log "------------------------------------------------------------"
Log "✅ Node.js Docker Project Initializer"
Log "------------------------------------------------------------"
Log "🕒 Timestamp: $(Get-Date)"
Log "📂 Working Directory: $PWD"

# 1️⃣ Check Docker CLI
try {
    $dockerVersion = docker --version
    Log "✔️ Docker CLI found: $dockerVersion"
} catch {
    Log "❌ ERROR: Docker CLI not found. Install Docker Desktop first."
    Save-Log
    exit 1
}

# 2️⃣ Check Docker Daemon
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect") {
        Log "⚠️ WARNING: Docker daemon not responding. Make sure Docker Desktop is running."
    } else {
        Log "✔️ Docker daemon is responsive."
    }
} catch {
    Log "⚠️ WARNING: Could not verify Docker daemon."
}

# 3️⃣ Check for package.json
$PackageJson = Join-Path $PWD "package.json"
if (!(Test-Path $PackageJson)) {
    Log "❌ ERROR: package.json not found."
    Log "➡️ You need to initialize a Node project here first:"
    Log "   npm init -y"
    Save-Log
    exit 1
}
Log "✔️ Found package.json"

# 4️⃣ Check for package-lock.json
$PackageLock = Join-Path $PWD "package-lock.json"
if (!(Test-Path $PackageLock)) {
    Log "❌ ERROR: package-lock.json not found."
    Log "➡️ You should install dependencies to generate it:"
    Log "   npm install"
    Save-Log
    exit 1
}
Log "✔️ Found package-lock.json"

# 5️⃣ Check for server.js
$ServerFile = Join-Path $PWD "server.js"
$serverExists = Test-Path $ServerFile

if ($serverExists -and (-not $Force)) {
    Log "✔️ server.js already exists: $ServerFile"
    Log "❌ Aborting to avoid overwriting."
    Log "➡️ Tip: Use -Force to overwrite."
    Save-Log
    exit 0
}

if ($serverExists -and $Force) {
    Log "⚠️ Overwriting existing server.js (because -Force is set)."
}

# 6️⃣ Offer to create server.js if missing
if (-not $serverExists -or $Force) {
    Log "❓ Generating production-ready Express server.js..."
    $serverContent = @"
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Docker!');
});

app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
"@

    try {
        $serverContent | Out-File -Encoding utf8 -FilePath $ServerFile -Force
        Log "✅ Created server.js at: $ServerFile"
    } catch {
        Log "❌ ERROR: Failed to write server.js"
        Log $_
        Save-Log
        exit 1
    }
}

Log "✅ All checks complete!"
Log "✅ Your project now has:"
Log "   - package.json"
Log "   - package-lock.json"
Log "   - server.js"
Log "✅ You're ready to build:"
Log "   docker build -t yourimagename ."
Log "------------------------------------------------------------"
Save-Log
