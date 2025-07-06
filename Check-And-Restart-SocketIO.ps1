$ErrorActionPreference = "Stop"

# === CONFIG ===
$backendDir = "E:\VedicMatchMaking\matchmaking-app-backend"
$socketUrl = "http://localhost:3000/socket.io/?EIO=4&transport=polling"
$logPath = "$backendDir\logs\socket-check.log"
$maxRetries = 3
$retryDelay = 5

if (-not (Test-Path "$backendDir\logs")) {
    New-Item -ItemType Directory -Path "$backendDir\logs" | Out-Null
}

Function Test-SocketIO {
    try {
        $response = Invoke-WebRequest -Uri $socketUrl -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Socket.IO server is responding." -ForegroundColor Green
            Add-Content $logPath "[$(Get-Date)] ✅ Socket.IO is up"
            return $true
        } else {
            Write-Host "⚠️ Received status: $($response.StatusCode)" -ForegroundColor Yellow
            Add-Content $logPath "[$(Get-Date)] ⚠️ Status $($response.StatusCode)"
            return $false
        }
    } catch {
        Write-Warning "❌ Socket.IO not responding: $($_.Exception.Message)"
        Add-Content $logPath "[$(Get-Date)] ❌ Error: $($_.Exception.Message)"
        return $false
    }
}

# === MAIN FLOW ===
Write-Host "`n🔍 Checking Socket.IO connectivity..." -ForegroundColor Cyan

for ($i = 1; $i -le $maxRetries; $i++) {
    if (Test-SocketIO) {
        break
    }

    if ($i -lt $maxRetries) {
        Write-Host "`n🔄 Attempt $i failed. Restarting API Gateway and retrying in $retryDelay seconds..." -ForegroundColor Yellow
        docker compose -f "$backendDir\docker-compose.yml" restart api-gateway | Out-Null
        Start-Sleep -Seconds $retryDelay
    } else {
        Write-Host "`n❌ Socket.IO is still down after $maxRetries attempts. Please check backend logs." -ForegroundColor Red
        exit 1
    }
}
