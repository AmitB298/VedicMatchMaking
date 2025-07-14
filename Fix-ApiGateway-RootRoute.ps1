<#
.SYNOPSIS
  Ensures / route is present in server.js for Express API Gateway.

.DESCRIPTION
  - Locates server.js in matchmaking-app-backend/services/api-gateway
  - Checks if app.get('/') exists
  - If missing, injects it automatically after first use(express())
#>

$gatewayPath = "matchmaking-app-backend/services/api-gateway/server.js"

Write-Host "🛠️ Fixing API Gateway server.js..." -ForegroundColor Cyan

# 1️⃣ Check if file exists
if (-not (Test-Path $gatewayPath)) {
    Write-Error "❌ Cannot find server.js at $gatewayPath"
    exit 1
}

# 2️⃣ Load contents
$lines = Get-Content $gatewayPath
$hasRootRoute = $lines | Select-String "app\.get\('/'\s*,"

if ($hasRootRoute) {
    Write-Host "✅ Root / route already present. No changes needed." -ForegroundColor Green
    exit 0
}

Write-Host "⚠️ No root / route found. Injecting now..." -ForegroundColor Yellow

# 3️⃣ Define new route to inject
$newRoute = @"
app.get('/', (req, res) => {
  res.send('✅ API Gateway is running');
});
"@

# 4️⃣ Decide where to insert
$injectIndex = ($lines | Select-String "express\(\)" | Select-Object -First 1).LineNumber

if ($injectIndex -eq $null) {
    Write-Error "❌ Could not find a good place to inject the route. Please add it manually."
    exit 1
}

# 5️⃣ Inject after detected line
$before = $lines[0..($injectIndex)]
$after  = $lines[($injectIndex + 1)..($lines.Length - 1)]

$newContent = $before + $newRoute + $after
$newContent | Set-Content -Encoding UTF8 $gatewayPath

Write-Host "✅ Root / route injected successfully!" -ForegroundColor Green
Write-Host "✨ You can now rebuild the container with:"
Write-Host "   docker-compose up --build -d" -ForegroundColor Cyan
