# Create-ApiGateway-WithUsersRoute.ps1
$ErrorActionPreference = "Stop"

$gatewayPath = "matchmaking-app-backend/services/api-gateway"
$indexPath = Join-Path $gatewayPath "index.js"
$packagePath = Join-Path $gatewayPath "package.json"
$dockerComposePath = "matchmaking-app-backend/docker-compose.yml"

# Step 1: Create folder structure
if (-not (Test-Path $gatewayPath)) {
    Write-Host "📁 Creating API Gateway folder structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $gatewayPath | Out-Null
}

# Step 2: Write Express server with MongoDB user insertion
if (-not (Test-Path $indexPath)) {
    Write-Host "🧩 Writing Express + MongoDB API to index.js..." -ForegroundColor Cyan
@"
const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');

const app = express();
app.use(cors());
app.use(express.json());

const uri = 'mongodb://mongo:27017';
const client = new MongoClient(uri);

app.post('/api/v1/users', async (req, res) => {
    try {
        await client.connect();
        const db = client.db('vedicmatch');
        const { name, email } = req.body;
        const result = await db.collection('users').insertOne({ name, email });
        res.status(201).json({ insertedId: result.insertedId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Insert failed' });
    }
});

app.get('/api/v1/health', (req, res) => {
    res.json({ status: 'ok' });
});

app.listen(3000, () => {
    console.log('✅ API Gateway running on port 3000');
});
"@ | Set-Content $indexPath -Encoding UTF8
} else {
    Write-Host "✅ index.js already exists." -ForegroundColor Yellow
}

# Step 3: Create basic package.json if not present
if (-not (Test-Path $packagePath)) {
    Write-Host "📦 Creating package.json..." -ForegroundColor Cyan
@"
{
  "name": "api-gateway",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "express": "^4.19.2",
    "cors": "^2.8.5",
    "mongodb": "^6.5.0"
  }
}
"@ | Set-Content $packagePath -Encoding UTF8
}

# Step 4: Install npm packages
Push-Location $gatewayPath
Write-Host "📦 Installing npm packages..." -ForegroundColor Cyan
npm install
Pop-Location

# Step 5: Ensure port 3000 exposed in docker-compose.yml
$composeContent = Get-Content $dockerComposePath -Raw
if ($composeContent -notmatch "api-gateway:\s*(\n\s+.*)*?ports:\s*(\n\s+.*)?3000:3000") {
    Write-Host "🔧 Adding port 3000 exposure to docker-compose.yml..." -ForegroundColor Cyan

    $updatedCompose = $composeContent -replace "(api-gateway:\s*(\n\s+.*)+?)", {
        param($match)
        return "$($match.Value)`n    ports:`n      - '3000:3000'"
    }

    Copy-Item $dockerComposePath "$dockerComposePath.bak" -Force
    $updatedCompose | Set-Content $dockerComposePath -Encoding UTF8
    Write-Host "✅ docker-compose.yml updated." -ForegroundColor Green
} else {
    Write-Host "✅ Port 3000 already exposed." -ForegroundColor Yellow
}

# Step 6: Restart API Gateway
Write-Host "🔄 Restarting API Gateway container..." -ForegroundColor Cyan
docker compose -f $dockerComposePath restart api-gateway

Write-Host "`n✅ API Gateway with Express/MongoDB is ready at http://localhost:3000" -ForegroundColor Green
