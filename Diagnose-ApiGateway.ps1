$ErrorActionPreference = "Stop"

# === CONFIG ===
$backendRoot = "E:\VedicMatchMaking\matchmaking-app-backend"
$composeFile = "$backendRoot\docker-compose.yml"
$apiGatewayName = "api-gateway"
$apiGatewayPath = Join-Path $backendRoot "services\$apiGatewayName"
$logPath = Join-Path $apiGatewayPath "logs"
$logFile = Join-Path $logPath "api-gateway.log"

Write-Host "`n🔍 Diagnosing API Gateway container..." -ForegroundColor Cyan

# === Ensure 'logs' folder exists ===
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    Write-Host "📁 Created log directory: $logPath" -ForegroundColor Yellow
}

# === Check if API Gateway container is up ===
$containerUp = docker ps --format "{{.Names}}" | Where-Object { $_ -like "*$apiGatewayName*" }

if (-not $containerUp) {
    Write-Warning "❌ API Gateway container not found. Attempting to rebuild..."
    docker compose -f $composeFile up -d $apiGatewayName
    Start-Sleep -Seconds 5
}

# === Get logs ===
try {
    Write-Host "`n📜 Checking logs for API Gateway..." -ForegroundColor Yellow
    docker compose -f $composeFile logs $apiGatewayName | Tee-Object -FilePath $logFile -Encoding utf8
    Write-Host "✅ Logs saved to $logFile" -ForegroundColor Green
} catch {
    Write-Warning "❌ Failed to capture logs. Please ensure the container is defined and running."
    exit 1
}

# === Auto-open logs in Notepad (optional) ===
try {
    Start-Process notepad $logFile
} catch {
    Write-Warning "⚠️ Could not open log file in Notepad."
}

Write-Host "`n✅ Diagnosis complete." -ForegroundColor Green
