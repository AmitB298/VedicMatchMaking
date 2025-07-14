<#
.SYNOPSIS
  Industry-level Dockerfile generator for production use.
.DESCRIPTION
  Checks Docker CLI & daemon. Creates a production-ready Dockerfile for chosen stack.
.PARAMETER Force
  Overwrites existing Dockerfile if present.
.EXAMPLE
  .\Generate-ProductionDockerfile.ps1
#>

param(
    [switch]$Force
)

$LogFile = Join-Path $PWD "docker-generator-log.txt"
$Log = @()

function Log {
    param([string]$Message)
    Write-Host $Message
    $Log += $Message
}

function Save-Log {
    $Log | Out-File -Encoding utf8 -FilePath $LogFile
}

# Start
Log "------------------------------------------------------------"
Log "✅ Production Dockerfile Generator"
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

# 3️⃣ Check for existing Dockerfile
$DockerfilePath = Join-Path $PWD "Dockerfile"
$dockerfileExists = Test-Path $DockerfilePath

if ($dockerfileExists -and (-not $Force)) {
    Log "⚠️ WARNING: Dockerfile already exists at: $DockerfilePath"
    Log "❌ Aborting to avoid overwriting existing work."
    Log "➡️ Tip: Use -Force to overwrite."
    Save-Log
    exit 0
}

# 4️⃣ Choose Stack
Log "❓ Choose your application stack:"
$choices = @(
    "1. Node.js (production ready)"
    "2. Python (production ready)"
    "3. Java JAR (production ready)"
    "4. Exit"
)
$choices | ForEach-Object { Write-Host $_ }

$selection = Read-Host "Enter choice number"

switch ($selection) {
    "1" {
        $dockerfileContent = @"
# syntax=docker/dockerfile:1
FROM node:20-slim

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
"@
        Log "✔️ Selected Node.js production template."
    }
    "2" {
        $dockerfileContent = @"
# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["gunicorn", "app:app"]
"@
        Log "✔️ Selected Python production template."
    }
    "3" {
        $dockerfileContent = @"
# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY *.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
"@
        Log "✔️ Selected Java JAR production template."
    }
    Default {
        Log "❌ User exited or chose invalid option."
        Save-Log
        exit 0
    }
}

# 5️⃣ Write Dockerfile
try {
    $dockerfileContent | Out-File -Encoding utf8 -FilePath $DockerfilePath -Force
    Log "✅ Dockerfile created at: $DockerfilePath"
} catch {
    Log "❌ ERROR: Failed to write Dockerfile."
    Log $_
    Save-Log
    exit 1
}

# 6️⃣ Done
Log "✅ Success! You can now build your image:"
Log "   docker build -t yourimagename ."
Log "------------------------------------------------------------"
Save-Log
