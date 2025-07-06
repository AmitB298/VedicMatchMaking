$ErrorActionPreference = "Stop"

# === Config ===
$socketUrl = "http://localhost:3000/socket.io/?EIO=4&transport=polling"
$gatewayPath = "E:\VedicMatchMaking\matchmaking-app-backend\api-gateway"
$indexFile = Join-Path $gatewayPath "index.js"

Write-Host "🔍 Checking Socket.IO connectivity..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $socketUrl -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200 -and $response.Content -match '"sid"') {
        Write-Host "✅ Socket.IO is working and reachable." -ForegroundColor Green
        exit 0
    } elseif ($response.Content -match "Cannot GET /socket.io/") {
        Write-Host "⚠️ Detected 'Cannot GET /socket.io/' error. Backend is running but Socket.IO is NOT attached." -ForegroundColor Yellow
    } else {
        Write-Host "❗ Unexpected response received." -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Socket.IO endpoint is not responding. Backend may be down." -ForegroundColor Red
    exit 1
}

# === Suggest Fixes if index.js is accessible ===
if (Test-Path $indexFile) {
    Write-Host "`n📄 Found index.js at $indexFile" -ForegroundColor Green
    $content = Get-Content $indexFile -Raw

    if ($content -match "app\.listen") {
        Write-Host "⚙️ Detected app.listen – likely missing Socket.IO attachment." -ForegroundColor Yellow

        $patchedContent = @"
const express = require('express');
const app = express();
const http = require('http').createServer(app);
const { Server } = require('socket.io');
const io = new Server(http, {
  cors: { origin: "*" }
});

io.on('connection', socket => {
  console.log('✅ Client connected:', socket.id);
});

app.use(express.json());
app.use('/', require('./routes'));

http.listen(3000, () => {
  console.log("🚀 API Gateway running with Socket.IO on port 3000");
});
"@

        $backupPath = "$indexFile.bak"
        Copy-Item $indexFile $backupPath -Force
        Write-Host "🛡️ Backed up index.js to $backupPath" -ForegroundColor Cyan

        Set-Content -Path $indexFile -Value $patchedContent -Encoding utf8
        Write-Host "✅ Patched index.js to use http + socket.io." -ForegroundColor Green

        # Restart backend
        Write-Host "`n♻️ Restarting backend (api-gateway) with Docker Compose..." -ForegroundColor Cyan
        docker compose -f "$gatewayPath\..\docker-compose.yml" restart api-gateway
    } else {
        Write-Host "✅ index.js likely already uses http + socket.io." -ForegroundColor Green
    }
} else {
    Write-Warning "⚠️ index.js not found. Please verify gateway path or entry point."
}

Write-Host "`n🧪 Run this script again to verify if Socket.IO is fixed." -ForegroundColor Cyan
