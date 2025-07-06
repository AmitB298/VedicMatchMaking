$ErrorActionPreference = "Stop"

$composePath = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$backupPath = "$composePath.bak"

# Step 1: Backup
if (-not (Test-Path $composePath)) {
    Write-Error "❌ Cannot find docker-compose.yml at $composePath"
    exit 1
}
Copy-Item $composePath $backupPath -Force
Write-Host "📦 Backup saved at $backupPath" -ForegroundColor Gray

# Step 2: Read and clean line 63 region
$lines = Get-Content $composePath
$total = $lines.Count

if ($total -lt 63) {
    Write-Warning "⚠️ docker-compose.yml has fewer than 63 lines."
    exit 1
}

$lineIndex = 62 # 0-based
$context = $lines[($lineIndex - 3)..($lineIndex + 3)]

Write-Host "`n🔍 Context around line 63:" -ForegroundColor Cyan
$context | ForEach-Object { Write-Host $_ }

# Step 3: Fix common indentation/quote issues
$cleaned = @()
foreach ($line in $lines) {
    $fixed = $line -replace "`t", "  "         # replace tabs
    $fixed = $fixed -replace '"(\d+:\d+)"', "'$1'"  # fix ports with wrong quotes
    $fixed = $fixed -replace ":(\s*)$", ": ''" # fix missing key after colon
    $cleaned += $fixed
}

Set-Content -Path $composePath -Value $cleaned -Encoding UTF8
Write-Host "`n✅ Attempted YAML cleanup." -ForegroundColor Green

# Step 4: Validate
Push-Location (Split-Path $composePath)
Write-Host "`n🧪 Running docker compose config for validation..." -ForegroundColor Cyan
try {
    docker compose config | Out-Null
    Write-Host "✅ YAML is valid." -ForegroundColor Green
} catch {
    Write-Host "❌ YAML still has issues. Please manually check line 63+" -ForegroundColor Red
}
Pop-Location
