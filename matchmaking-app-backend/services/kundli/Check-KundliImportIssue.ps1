# Check-KundliAPI.ps1
# Purpose: Ensure kundli_api.py has a __main__ block and start it safely.

Write-Host "`n🔍 Checking kundli_api.py setup..." -ForegroundColor Cyan

# Step 1: Check if the file exists
$apiFile = "kundli_api.py"
if (-not (Test-Path $apiFile)) {
    Write-Host "❌ File '$apiFile' not found in current directory." -ForegroundColor Red
    exit 1
}

# Step 2: Read file content
$content = Get-Content $apiFile -Raw

# Step 3: Ensure __main__ block exists
if ($content -notmatch "if\s+__name__\s*==\s*['""]__main__['""]") {
    Write-Host "⚠️  Missing 'if __name__ == \"__main__\"' block. Appending it..." -ForegroundColor Yellow

    $mainBlock = @'
if __name__ == "__main__":
    try:
        print("🔮 Starting Kundli Match API...")
        app.run(host="0.0.0.0", port=5055)
    except Exception as e:
        print("❌ Fatal error on startup:", e)
'@

    Add-Content -Path $apiFile -Value "`n$mainBlock"
    Write-Host "✅ '__main__' block added." -ForegroundColor Green
} else {
    Write-Host "✅ '__main__' block already present." -ForegroundColor Green
}

# Step 4: Start the API in the current terminal
Write-Host "`n🚀 Running kundli_api.py..." -ForegroundColor Cyan
$python = if ($env:VIRTUAL_ENV) { "$env:VIRTUAL_ENV\Scripts\python.exe" } else { "python" }

& $python $apiFile
