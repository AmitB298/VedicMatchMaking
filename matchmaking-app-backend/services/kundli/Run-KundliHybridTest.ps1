# Run-KundliHybridTest.ps1
$pythonPath = ".\venv\Scripts\python.exe"
$scriptPath = "kundli_hybrid_matcher.py"

Write-Host "🧪 Testing Hybrid Kundli Matcher..."

if (!(Test-Path $scriptPath)) {
    Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

# Run it
try {
    & $pythonPath $scriptPath
} catch {
    Write-Host "❌ Error running hybrid matcher: $_" -ForegroundColor Red
}
