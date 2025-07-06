param(
    [string]$EnvPath = ".\matchmaking-app-backend\.env",
    [string]$NewMongoUri = "mongodb+srv://vedicmatchmakingapp:VedicMatch2025Secure@cluster0.jm9avfj.mongodb.net/VedicMatchMaking?retryWrites=true&w=majority&appName=Cluster0"
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking .env MongoDB URI Updater" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------"

# 1. Verify .env exists
if (!(Test-Path $EnvPath)) {
    Write-Host "❌ ERROR: .env file not found at path: $EnvPath" -ForegroundColor Red
    exit 1
}

# 2. Create Backup
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupPath = "$EnvPath.bak.$timestamp"
Copy-Item $EnvPath $backupPath
Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Green

# 3. Read lines
$lines = Get-Content $EnvPath

# 4. Replace or add MONGODB_URI
$found = $false
$newLines = @()
foreach ($line in $lines) {
    if ($line -match "^MONGODB_URI=") {
        $newLines += "MONGODB_URI=$NewMongoUri"
        $found = $true
    }
    else {
        $newLines += $line
    }
}
if (-not $found) {
    $newLines += "MONGODB_URI=$NewMongoUri"
}

# 5. Write back
$newLines | Set-Content $EnvPath
Write-Host "✅ .env file updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📜 Final .env content:"
Get-Content $EnvPath | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }

Write-Host ""
Write-Host "✨ Done! Your .env is now ready to use." -ForegroundColor Cyan
