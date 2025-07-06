<#
.SYNOPSIS
    Deploys the Vedic Matchmaking application using Docker Compose.

.DESCRIPTION
    - Validates Docker and Docker Compose availability.
    - Optionally prunes unused Docker resources.
    - Builds and launches all containers.
    - Checks backend, frontend, and photo verifier service status.
    - Provides access URLs.

.EXAMPLE
    .\Deploy-VedicApp.ps1
#>

# ---------------- CONFIG ----------------
$composePath = ".\docker-compose.yml"
$backendUrl = "http://localhost:3000/"
$webUrl = "http://localhost:5173/"
$verifierUrl = "http://localhost:5000/"
# ----------------------------------------

Write-Host "`n🚀 Starting Vedic Matchmaking deployment..." -ForegroundColor Cyan

# --- Step 1: Validate Environment ---
function Check-Command($command) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Error "❌ '$command' is not installed or not in PATH."
        exit 1
    }
}
Check-Command "docker"
Check-Command "docker-compose"

# --- Step 2: Check docker-compose.yml ---
if (-not (Test-Path $composePath)) {
    Write-Error "❌ docker-compose.yml not found at $composePath"
    exit 1
}

# --- Step 3: Optional Prune ---
$prune = Read-Host "⚠️ Do you want to clean up unused Docker resources? (y/n)"
if ($prune -eq "y") {
    Write-Host "🧹 Cleaning Docker system..."
    docker system prune -f
    docker volume prune -f
}

# --- Step 4: Docker Compose Up ---
Write-Host "🔧 Building containers and starting services..." -ForegroundColor Yellow
docker-compose -f $composePath up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Docker Compose failed to start containers."
    exit 1
}

# --- Step 5: Health Checks ---
function Check-Service($name, $url) {
    Write-Host "`n🔍 Checking $name service at $url..." -ForegroundColor DarkCyan
    $response = $null
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 404) {
            Write-Host "✅ $name is reachable."
        } else {
            Write-Warning "⚠️ $name responded with status code: $($response.StatusCode)"
        }
    } catch {
        Write-Warning "❌ $name is not reachable. Exception: $_"
    }
}

Start-Sleep -Seconds 10
Check-Service "Backend" $backendUrl
Check-Service "Frontend" $webUrl
Check-Service "Photo Verifier" $verifierUrl

# --- Step 6: Show Summary ---
Write-Host "`n🌐 Access Points:" -ForegroundColor Cyan
Write-Host "   ✅ Web UI: $webUrl"
Write-Host "   ✅ Backend API: $backendUrl"
Write-Host "   ✅ Verifier API: $verifierUrl"
Write-Host "   ✅ MongoDB: mongodb://localhost:27017"

Write-Host "`n🎉 Deployment complete!" -ForegroundColor Green
