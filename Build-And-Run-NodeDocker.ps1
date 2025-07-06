# ---------------------------------------
# Build-And-Run-NodeDocker.ps1
# ---------------------------------------
# Author: ChatGPT | 2025-07-04
# Purpose: Automate Docker build and run for Node.js backend (VedicMatchMaking)
# ---------------------------------------

# 💥 Safe Defaults
$ImageName = "vedicmatchmaking-node"
$ContainerName = "vedicmatchmaking-container"
$AppPort = 3000

# 🧭 Step 0: Locate Dockerfile
Write-Host "`n🧭 Searching for Dockerfile under $PWD..." -ForegroundColor Cyan
$DockerfilePath = Get-ChildItem -Recurse -Filter "Dockerfile" -Path $PWD -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $DockerfilePath) {
    Write-Error "❌ ERROR: Dockerfile not found. Aborting."
    exit 1
}

$DockerfileFullPath = $DockerfilePath.FullName
$DockerContext = Split-Path -Parent $DockerfileFullPath
Write-Host "✅ Found Dockerfile at: $DockerfileFullPath`n" -ForegroundColor Green

# 🧹 Step 1: Clean up existing Docker containers/images
Write-Host "`n🧹 Step 1: Cleaning up existing Docker containers and images..." -ForegroundColor Cyan
docker container prune -f | Out-Null
docker image prune -a -f | Out-Null
docker volume prune -f | Out-Null
docker system prune -a --volumes -f | Out-Null

# 🛑 Step 2: Restart Docker Desktop
Write-Host "`n🛑 Step 2: Restarting Docker Desktop for clean session..." -ForegroundColor Magenta
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
Start-Sleep -Seconds 10

# 🔨 Step 3: Build Docker Image
Write-Host "`n🔨 Step 3: Building Docker image '$ImageName'..." -ForegroundColor Yellow
docker build -t $ImageName "$DockerContext"

# 🧽 Step 4: Remove old container (ignore errors)
Write-Host "`n🧽 Step 4: Removing old container (if exists)..." -ForegroundColor Gray
docker rm -f $ContainerName | Out-Null

# 🚀 Step 5: Run the container
Write-Host "`n🚀 Step 5: Running Docker container '$ContainerName'..." -ForegroundColor Yellow
docker run -d --name $ContainerName -p "${AppPort}:${AppPort}" $ImageName

# ✅ Step 6: Confirm
Write-Host "`n✅ Done. Running containers:" -ForegroundColor Green
docker ps

Write-Host "`n🌐 Access your app at http://localhost:$AppPort/" -ForegroundColor Cyan
