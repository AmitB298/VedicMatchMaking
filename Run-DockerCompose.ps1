$ErrorActionPreference = "Stop"
Clear-Host
Write-Host "🧩 Vedic Matchmaking - Docker Compose Orchestration" -ForegroundColor Cyan

$composeFile = "E:\VedicMatchMaking\docker-compose.yml"

# Step 1: Validate docker-compose.yml
Write-Host "`n🔍 Validating Docker Compose file existence..." -ForegroundColor Yellow
if (-Not (Test-Path $composeFile)) {
    Write-Host "❌ ERROR: docker-compose.yml not found at: $composeFile" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Found docker-compose.yml at: $composeFile" -ForegroundColor Green

# Step 2: Prune old containers, images, volumes
Write-Host "`n🧹 Step 1: Cleaning up previous Docker containers, networks, volumes..." -ForegroundColor Yellow
docker compose -f $composeFile down --volumes --remove-orphans

# Step 3: Build and up
Write-Host "`n🚀 Step 2: Building and starting containers..." -ForegroundColor Yellow
docker compose -f $composeFile up -d --build

# Step 4: Health Check
Start-Sleep -Seconds 5
$running = docker ps --filter "name=vedicmatchmaking-api" --format "{{.Names}}"
if ($running -eq "vedicmatchmaking-api") {
    Write-Host "`n✅ App is running at: http://localhost:3000/" -ForegroundColor Green
} else {
    Write-Host "`n❌ App failed to start properly." -ForegroundColor Red
    docker compose -f $composeFile logs
}
