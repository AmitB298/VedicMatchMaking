# Setup-KundliMatchService.ps1
Write-Host "🔮 Setting up Kundli Match Service..." -ForegroundColor Cyan

# Step 1: Ensure you're in the correct directory
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $basePath

# Step 2: Create virtual environment if not present
if (-not (Test-Path "$basePath\venv")) {
    Write-Host "📁 Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
} else {
    Write-Host "✅ Virtual environment exists." -ForegroundColor Green
}

# Step 3: Activate venv
$activateScript = "$basePath\venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    Write-Host "🐍 Activating virtual environment..." -ForegroundColor Yellow
    & $activateScript
} else {
    Write-Warning "⚠️ Could not activate virtual environment — please activate manually."
}

# Step 4: Create requirements.txt (safe overwrite)
@"
flask==3.1.1
flask-cors==4.0.0
pyswisseph==2.10.3.2
"@ | Set-Content -Encoding UTF8 "$basePath\requirements.txt"

# Step 5: Install dependencies
Write-Host "📦 Installing Python dependencies..." -ForegroundColor Cyan
pip install -r "$basePath\requirements.txt"

# Step 6: Start Flask API in background
$apiScript = "$basePath\kundli_api.py"
if (Test-Path $apiScript) {
    Write-Host "🚀 Launching kundli_api.py..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "python $apiScript" -WindowStyle Hidden
    Start-Sleep -Seconds 5
} else {
    Write-Host "❌ kundli_api.py not found in $basePath" -ForegroundColor Red
    exit 1
}

# Step 7: Test POST request
Write-Host "🔍 Sending test request to API..." -ForegroundColor Cyan
$body = @{
    person1 = @{
        name = "amit banerjee"
        birth_date = "1992-11-08"
        birth_time = "07:25:05"
        latitude = 23.20383
        longitude = 81.97904
    }
    person2 = @{
        name = "aditi bhattacharya"
        birth_date = "1994-09-03"
        birth_time = "14:25:00"
        latitude = 25.473034
        longitude = 81.878357
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5055/api/kundli/match" -Method POST -Body $body -ContentType "application/json"
    Write-Host "`n📝 Match Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "❌ Failed to get response from API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Kundli Matching Service Setup Complete!" -ForegroundColor Cyan
