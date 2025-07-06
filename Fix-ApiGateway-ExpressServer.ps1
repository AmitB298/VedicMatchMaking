$gatewayPath = "matchmaking-app-backend/services/api-gateway"
$entryFile = "$gatewayPath/server.js"
$packageFile = "$gatewayPath/package.json"

if (-not (Test-Path $gatewayPath)) {
    Write-Host "📁 Creating API Gateway folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $gatewayPath -Force | Out-Null
}

Write-Host "🧩 Writing Express + Socket.IO server..." -ForegroundColor Cyan

@"
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok' });
});

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

io.on('connection', (socket) => {
  console.log('🔌 New WebSocket connection');
});

server.listen(3000, () => console.log('🚀 API Gateway listening on port 3000'));
"@ | Set-Content $entryFile

@"
{
  "name": "api-gateway",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.19.2",
    "cors": "^2.8.5",
    "socket.io": "^4.7.2"
  }
}
"@ | Set-Content $packageFile

Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
Push-Location $gatewayPath
npm install
Pop-Location

Write-Host "🔄 Restarting API Gateway container..." -ForegroundColor Cyan
docker compose -f "matchmaking-app-backend/docker-compose.yml" restart api-gateway

Write-Host "`n✅ API Gateway is now running Express + Socket.IO at http://localhost:3000" -ForegroundColor Green
