# Check-KundliAPI.ps1
# Ensure kundli_api.py has a __main__ block and run it

Write-Host "`n🔍 Checking kundli_api.py setup..." -ForegroundColor Cyan

$apiFile = "kundli_api.py"

if (-not (Test-Path $apiFile)) {
    Write-Host "❌ File '$apiFile' not found." -ForegroundColor Red
    exit 1
}

$content = Get-Content $apiFile -Raw

if ($content -notmatch "if\s+__name__\s*==\s*['""]__main__['""]") {
    Write-Host "⚠️  Missing '__main__' block. Appending..." -ForegroundColor Yellow

    $mainBlock = @'
if __name__ == "__main__":
    try:
        print("🔮 Starting Kundli Match API...")
        app.run(host="0.0.0.0", port=5055)
    except Exception as e:
        print("❌ Startup error:", e)
'@

    Add-Content -Path $apiFile -Value "`n$mainBlock"
    Write-Host "✅ '__main__' block added." -ForegroundColor Green
} else {
    Write-Host "✅ '__main__' block exists." -ForegroundColor Green
}

# Run kundli_api.py
$python = if ($env:VIRTUAL_ENV) { "$env:VIRTUAL_ENV\Scripts\python.exe" } else { "python" }

Write-Host "`n🚀 Running kundli_api.py using $python..." -ForegroundColor Cyan
& $python $apiFile
