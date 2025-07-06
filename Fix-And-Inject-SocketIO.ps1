$ErrorActionPreference = "Stop"

$backendPath = "E:\VedicMatchMaking\matchmaking-app-backend"
$gatewayPath = Join-Path $backendPath "api-gateway"
$composeFile = Join-Path $backendPath "docker-compose.yml"

Write-Host "`n🔧 Fixing Socket.IO setup..." -ForegroundColor Cyan

# Step 1: Create api-gateway if missing
if (-not (Test-Path $gatewayPath)) {
    Write-Host "📁 Creating 'api-gateway' folder..." -ForegroundColor Yellow
    New-Item -Path $gatewayPath -ItemType Directory | Out-Null

    # Create basic Express + Socket.IO server
    @"
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

io.on('connection', (socket) => {
  console.log('✅ User connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('❌ User disconnected:', socket.id);
  });
});

app.get('/', (req, res) => res.send('API Gateway with Socket.IO'));
server.listen(3000, () => console.log('🚀 API Gateway running on port 3000'));
"@ | Set-Content "$gatewayPath\index.js"

    # Add package.json
    @"
{
  "name": "api-gateway",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "socket.io": "^4.7.2"
  }
}
"@ | Set-Content "$gatewayPath\package.json"

    Write-Host "✅ Injected Express + Socket.IO server in 'api-gateway'." -ForegroundColor Green
} else {
    Write-Host "📦 'api-gateway' folder already exists." -ForegroundColor Yellow
}

# Step 2: Ensure Docker Compose exposes port 3000
if (Test-Path $composeFile) {
    $composeText = Get-Content $composeFile -Raw
    if ($composeText -notmatch "3000:3000") {
        Write-Host "🔌 Adding port 3000 to docker-compose.yml..." -ForegroundColor Yellow
        $composeText = $composeText -replace "(api-gateway:\s*\n(?:.*\n)*?)(\s*ports:\s*\n)", "`$1`$2      - '3000:3000'`n"
        Set-Content $composeFile -Value $composeText -Encoding UTF8
        Write-Host "✅ Port 3000 exposed in docker-compose.yml." -ForegroundColor Green
    } else {
        Write-Host "✅ Port 3000 already exposed." -ForegroundColor Green
    }
} else {
    Write-Host "❌ docker-compose.yml not found. Cannot expose port." -ForegroundColor Red
}

# Step 3: Install dependencies
Push-Location $gatewayPath
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing npm dependencies..." -ForegroundColor Cyan
    npm install
} else {
    Write-Host "📦 Dependencies already installed." -ForegroundColor Yellow
}
Pop-Location

# Step 4: Restart docker-compose
Write-Host "`n🔄 Restarting backend stack..." -ForegroundColor Cyan
Push-Location $backendPath
docker compose up -d --build
Pop-Location

Write-Host "`n🎉 Socket.IO gateway is ready at http://localhost:3000" -ForegroundColor Green
