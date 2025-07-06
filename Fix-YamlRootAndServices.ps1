$ErrorActionPreference = "Stop"

$composePath = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$backupPath = "$composePath.bak"

# Backup
Copy-Item $composePath $backupPath -Force
Write-Host "📦 Backup saved at $backupPath" -ForegroundColor Gray

# Load YAML lines
$lines = Get-Content $composePath -Raw -Encoding UTF8 -ErrorAction Stop
$linesArray = $lines -split "`n"

# Step 1: Ensure 'version' and 'services:' at top
if ($lines -notmatch "^version:") {
    $lines = "version: '3.9'`nservices:`n" + ($linesArray | ForEach-Object { "  $_" }) -join "`n"
    Write-Host "🔧 Injected missing 'version' and 'services:' root keys." -ForegroundColor Yellow
}

# Step 2: Save and re-test
Set-Content $composePath -Value $lines -Encoding UTF8
Write-Host "✅ Updated docker-compose.yml" -ForegroundColor Green

# Step 3: Validate YAML again
Push-Location (Split-Path $composePath)
Write-Host "`n🧪 Validating final docker-compose.yml..." -ForegroundColor Cyan
try {
    docker compose config | Out-Null
    Write-Host "✅ YAML is now valid!" -ForegroundColor Green
} catch {
    Write-Error "❌ YAML is still invalid. Check indentation and syntax manually."
}
Pop-Location
