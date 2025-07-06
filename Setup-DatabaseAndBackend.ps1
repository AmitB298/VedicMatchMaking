$ErrorActionPreference = "Stop"

# === CONFIG ===
$backendDir = "E:\VedicMatchMaking\matchmaking-app-backend"
$envFile = "$backendDir\.env"
$mongoUri = "mongodb://localhost:27017/vedicmatch"
$socketCheckUrl = "http://localhost:3000/socket.io/?EIO=4&transport=polling"
$logFile = "$backendDir\logs\backend-setup.log"
$dockerComposeFile = Join-Path $backendDir "docker-compose.yml"

# === STEP 1: Docker Check ===
Write-Host "🔍 Checking Docker status..." -ForegroundColor Cyan
try {
    docker version --format '{{.Server.Version}}' | Out-Null
    Write-Host "🐳 Docker is installed and running." -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not detected or not running." -ForegroundColor Red
    Write-Host "➡️ Please install/start Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# === STEP 2: Ensure .env has MONGO_URI ===
if (-not (Test-Path $envFile)) {
    New-Item -ItemType File -Path $envFile -Force | Out-Null
    Write-Host "🆕 Created .env file." -ForegroundColor Cyan
}
$content = Get-Content $envFile
if ($content -notmatch "MONGO_URI") {
    Add-Content $envFile "`nMONGO_URI=$mongoUri"
    Write-Host "✅ Added MONGO_URI to .env" -ForegroundColor Green
} else {
    Write-Host "✅ MONGO_URI already exists in .env" -ForegroundColor Yellow
}

# === STEP 3: Start Docker containers ===
Write-Host "🚀 Starting Docker Compose services..." -ForegroundColor Cyan
try {
    docker compose -f $dockerComposeFile up -d | Tee-Object -FilePath $logFile
    Write-Host "✅ Docker containers launched." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to launch Docker Compose services." -ForegroundColor Red
    exit 1
}

# === STEP 4: Retry MongoDB connection ===
$maxAttempts = 3
$connected = $false
for ($i = 1; $i -le $maxAttempts; $i++) {
    Write-Host "🔄 Attempt $i to connect to MongoDB..." -ForegroundColor Cyan
    try {
        $result = mongosh "$mongoUri" --quiet --eval "db.stats()" | Out-String
        if ($result -match "db") {
            Write-Host "✅ MongoDB is reachable." -ForegroundColor Green
            $connected = $true
            break
        }
    } catch {
        Write-Host "⚠️ mongosh failed to connect. Retrying in 5s..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}
if (-not $connected) {
    Write-Host "❌ Failed to connect to MongoDB after $maxAttempts attempts." -ForegroundColor Red
    exit 1
}

# === STEP 5: Check WebSocket availability ===
Write-Host "📡 Checking WebSocket endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $socketCheckUrl -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ WebSocket server is live at $socketCheckUrl" -ForegroundColor Green
    } else {
        Write-Host "❗ WebSocket server responded with status $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Warning "⚠️ WebSocket check failed. Ensure backend services are ready."
}

# === COMPLETE ===
Write-Host "`n🎉 Backend + MongoDB setup complete and ready for Android + Web." -ForegroundColor Cyan
