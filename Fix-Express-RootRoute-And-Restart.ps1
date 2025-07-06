# Fix-Express-Dockerfile-And-Restart.ps1

Write-Host "`n🧩 Vedic Matchmaking - Dockerfile CMD Fix & Restart" -ForegroundColor Cyan

# Configurable paths
$projectRoot = "E:\VedicMatchMaking"
$dockerfilePath = Join-Path $projectRoot "matchmaking-app-backend\services\api-gateway\Dockerfile"
$expectedCmd = 'CMD ["node", "server.js"]'

# Step 1: Fix Dockerfile CMD if necessary
Write-Host "`n🔍 Checking Dockerfile entrypoint..."
if (Test-Path $dockerfilePath) {
    $dockerContent = Get-Content $dockerfilePath
    if (-not ($dockerContent -join "`n" -match 'CMD\s+\["node",\s*"server\.js"\]')) {
        # Remove any existing CMD lines
        $dockerContent = $dockerContent | Where-Object {$_ -notmatch '^CMD\s+\[.*\]'}
        $dockerContent += $expectedCmd
        $dockerContent | Set-Content $dockerfilePath -Encoding UTF8
        Write-Host "✏️ Dockerfile CMD fixed to run server.js" -ForegroundColor Green
    } else {
        Write-Host "✅ Dockerfile already has correct CMD" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Dockerfile not found at $dockerfilePath" -ForegroundColor Red
    exit 1
}

# Step 2: Stop existing containers
Write-Host "`n🧹 Stopping and removing old containers..." -ForegroundColor Yellow
cd $projectRoot
Start-Sleep -Seconds 1

docker-compose down

# Step 3: Rebuild and restart containers
Write-Host "`n🚀 Rebuilding and starting containers..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

docker-compose up --build -d

# Step 4: Test root route
Write-Host "`n🌐 Checking http://localhost:3000/ ..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Root route is working: $($response.Content.Substring(0, 80))..." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Unable to reach root route: $_" -ForegroundColor Red
}
