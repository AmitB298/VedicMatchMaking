$ErrorActionPreference = "Stop"

# === CONFIG ===
$gatewayPath = "matchmaking-app-backend\services\api-gateway"
$indexPath = Join-Path $gatewayPath "index.js"
$packageJsonPath = Join-Path $gatewayPath "package.json"
$dockerfilePath = Join-Path $gatewayPath "Dockerfile"
$logPath = Join-Path $gatewayPath "logs"
$composePath = "matchmaking-app-backend\docker-compose.yml"
$socketCheckUrl = "http://localhost:3000/socket.io/?EIO=4&transport=polling"

Write-Host "`n🔧 Fixing API Gateway..." -ForegroundColor Cyan

# === Step 1: Ensure folder exists ===
if (-not (Test-Path $gatewayPath)) {
    New-Item -Path $gatewayPath -ItemType Directory -Force | Out-Null
    Write-Host "📁 Created API Gateway folder at $gatewayPath" -ForegroundColor Yellow
}

# === Step 2: Inject proper Express + Socket.IO server ===
$indexContent = @'
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.get("/", (req, res) => res.send("✅ API Gateway is running"));

io.on("connection", (socket) => {
  console.log("✅ User connected to socket");
  socket.on("disconnect", () => {
    console.log("🔌 User disconnected from socket");
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 API Gateway running on http://localhost:${PORT}`);
});
'@

Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
Write-Host "✅ Injected Express + Socket.IO server into index.js" -ForegroundColor Green

# === Step 3: Create or update package.json ===
if (-not (Test-Path $packageJsonPath)) {
    $package = @{
        name = "api-gateway"
        version = "1.0.0"
        main = "index.js"
        scripts = @{ start = "node index.js" }
        $dependencies = @{}
        $dependencies = @{}
        \.Add("express", "^4.18.2")
        \.Add("socket.io", "^4.7.2")
        $package.dependencies = $dependencies
        $package.dependencies = $dependencies
    } | ConvertTo-Json -Depth 4
    Set-Content -Path $packageJsonPath -Value $package -Encoding UTF8
    Write-Host "📦 Created new package.json" -ForegroundColor Yellow
} else {
    Write-Host "📦 package.json already exists. Skipping..." -ForegroundColor Yellow
}

# === Step 4: Create Dockerfile if missing ===
if (-not (Test-Path $dockerfilePath)) {
@'
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
'@ | Set-Content $dockerfilePath -Encoding UTF8
Write-Host "🐳 Dockerfile created for api-gateway" -ForegroundColor Green
}

# === Step 5: Ensure port 3000 is exposed in docker-compose.yml ===
$yaml = Get-Content $composePath
if ($yaml -join "`n" -notmatch "3000:3000") {
    $yaml = $yaml -replace "(api-gateway:\s*[\s\S]*?ports:\s*)", '$1' + "`n      - `"`"3000:3000`"`""
    Set-Content $composePath $yaml -Encoding UTF8
    Write-Host "🛠️ Port 3000 exposed in docker-compose.yml" -ForegroundColor Green
} else {
    Write-Host "✅ Port 3000 already exposed in docker-compose.yml" -ForegroundColor Yellow
}

# === Step 6: Restart Docker services ===
Push-Location "matchmaking-app-backend"
Write-Host "`n🔄 Rebuilding and restarting API Gateway..." -ForegroundColor Cyan
docker compose up -d --build api-gateway
Pop-Location

Start-Sleep -Seconds 5

# === Step 7: Check Socket.IO endpoint ===
Write-Host "`n🌐 Checking Socket.IO endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $socketCheckUrl -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "🎉 Socket.IO is working at $socketCheckUrl" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Socket.IO responded with status $($response.StatusCode)"
    }
} catch {
    Write-Host "❌ Socket.IO not responding. Please check container logs." -ForegroundColor Red
}

Write-Host "`n✅ Done." -ForegroundColor Green
