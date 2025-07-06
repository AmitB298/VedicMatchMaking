# Fix-MissingApiRoute.ps1
$ErrorActionPreference = "Stop"

$gatewayPath = "matchmaking-app-backend\services\api-gateway"
$indexPath = Join-Path $gatewayPath "index.js"
$dockerComposePath = "matchmaking-app-backend\docker-compose.yml"

if (-not (Test-Path $indexPath)) {
    Write-Host "❌ index.js not found at $indexPath" -ForegroundColor Red
    return
}

$content = Get-Content $indexPath -Raw
if ($content -match "/api/v1/users") {
    Write-Host "✅ API route already exists in index.js" -ForegroundColor Green
    return
}

Write-Host "🧩 Injecting /api/v1/users route into index.js..." -ForegroundColor Cyan

$routeCode = @"
app.use(express.json());

app.post('/api/v1/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    const { MongoClient } = require('mongodb');
    const client = new MongoClient('mongodb://mongo:27017');
    await client.connect();
    const db = client.db('vedicmatch');
    const result = await db.collection('users').insertOne({ name, email });
    res.status(201).json({ insertedId: result.insertedId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Insert failed' });
  }
});
"@

# Add route to bottom
Add-Content $indexPath "`n$routeCode"

Write-Host "📦 Installing MongoDB driver..." -ForegroundColor Yellow
Push-Location $gatewayPath
npm install mongodb
Pop-Location

Write-Host "🔄 Restarting API Gateway container..." -ForegroundColor Cyan
docker compose -f $dockerComposePath restart api-gateway

Write-Host "`n✅ /api/v1/users route added successfully!" -ForegroundColor Green
Write-Host "🌐 You can now POST to http://localhost:3000/api/v1/users" -ForegroundColor Magenta
