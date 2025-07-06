param (
    [switch]$Force
)

Write-Host "`n🧠 Injecting Express root route and restarting Docker..." -ForegroundColor Cyan

# Locate the Express entry point file (avoid node_modules)
$entryFile = Get-ChildItem -Path ".\matchmaking-app-backend" -Recurse -Include *.js |
    Where-Object {
        $_.FullName -notmatch 'node_modules' -and
        (Get-Content $_.FullName -ErrorAction SilentlyContinue | Select-String 'express')
    } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $entryFile) {
    Write-Host "❌ Could not locate an Express entry file." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found Express entry file: $($entryFile.FullName)" -ForegroundColor Green
$content = Get-Content $entryFile.FullName -Raw

# Check if app.get("/") is already defined
if ($Force -or $content -notmatch 'app\.get\s*\(\s*["'']\/["'']') {
    Write-Host "🛠️ Injecting root route..." -ForegroundColor Yellow

    # Regex to find the app.listen(...) line
    $listenPattern = 'app\.listen\s*\(.*?\)\s*;'
    $rootRouteCode = @"
app.get("/", (req, res) => {
    res.send("Vedic Matchmaking API is running.");
});
"@

    if ($content -match $listenPattern) {
        $newContent = $content -replace $listenPattern, "$rootRouteCode`n$&"
        Set-Content -Path $entryFile.FullName -Value $newContent -Encoding UTF8
        Write-Host "✅ Root route injected." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Could not find app.listen(...) to inject route before. Aborting injection." -ForegroundColor Red
    }
} else {
    Write-Host "ℹ️ Root route already present. Skipping injection." -ForegroundColor Gray
}

# Stop Docker Compose
Write-Host "`n🧹 Stopping Docker containers..." -ForegroundColor Yellow
docker-compose down

# Rebuild Docker
Write-Host "`n🔨 Rebuilding containers..." -ForegroundColor Yellow
docker-compose build

# Start containers
Write-Host "`n🚀 Starting containers..." -ForegroundColor Yellow
docker-compose up -d

# Wait and test root route
Start-Sleep -Seconds 4
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Root route responded successfully: $($response.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "❌ Root route did not return 200. Status: $($response.StatusCode)" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Could not reach http://localhost:3000/ - $($_.Exception.Message)" -ForegroundColor Red
}
