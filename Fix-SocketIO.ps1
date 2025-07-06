$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing Socket.IO API Gateway..." -ForegroundColor Cyan

# === CONFIG ===
$backendPath = "E:\VedicMatchMaking\matchmaking-app-backend"
$composePath = Join-Path $backendPath "docker-compose.yml"
$expectedPort = "3000:3000"

# === STEP 1: Patch docker-compose.yml for port 3000
if (-not (Test-Path $composePath)) {
    Write-Host "❌ docker-compose.yml not found." -ForegroundColor Red
    exit 1
}

$composeContent = Get-Content $composePath -Raw
if ($composeContent -notmatch "3000:3000") {
    $composeContent = $composeContent -replace "(ports:\s*\n\s*-)", "`$1`n      - `"3000:3000`""
    Set-Content $composePath -Value $composeContent -Encoding utf8
    Write-Host "✅ Port 3000 added to docker-compose.yml" -ForegroundColor Green
} else {
    Write-Host "✅ Port 3000 already exposed." -ForegroundColor Yellow
}

# === STEP 2: Try to locate API Gateway by finding socket.io usage
Write-Host "`n🔎 Scanning backend folder for Socket.IO usage..." -ForegroundColor Cyan
$gatewayFolder = $null
$gatewayCandidates = Get-ChildItem $backendPath -Directory -Recurse | Where-Object {
    Test-Path (Join-Path $_.FullName "package.json")
}

foreach ($folder in $gatewayCandidates) {
    $jsFiles = Get-ChildItem -Path $folder.FullName -Recurse -Include *.js -ErrorAction SilentlyContinue
    foreach ($file in $jsFiles) {
        $lines = Get-Content $file.FullName
        if ($lines -match "socket\.io") {
            $gatewayFolder = $folder
            break
        }
    }
    if ($gatewayFolder) { break }
}

if (-not $gatewayFolder) {
    Write-Host "❌ Could not detect socket.io usage or API Gateway folder." -ForegroundColor Red
    Write-Host "💡 Tip: Make sure your socket.io code is committed and inside 'matchmaking-app-backend'." -ForegroundColor Yellow
    exit 1
}

# === STEP 3: Show confirmation
Write-Host "✅ Found API Gateway folder:" $gatewayFolder.FullName -ForegroundColor Green

# === STEP 4: Restart gateway
Write-Host "`n🔄 Restarting API Gateway container..." -ForegroundColor Cyan
docker compose -f $composePath restart api-gateway

Write-Host "`n🚀 Socket.IO fix complete." -ForegroundColor Green
