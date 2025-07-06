# Debug-KundliMatchAPI.ps1

$pythonPath = ".\venv\Scripts\python.exe"
$scriptPath = "kundli_api.py"
$logFile = "api_debug.log"
$uri = "http://127.0.0.1:5055/api/kundli/match"

# 🛑 Kill old Python servers
Write-Host "🔪 Killing old Python/Flask processes..."
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 🧹 Unlock and delete log file
if (Test-Path $logFile) {
    try {
        Remove-Item $logFile -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠️  Log file in use. Retrying..."
        Start-Sleep -Seconds 2
        Stop-Process -Name "python" -Force -ErrorAction SilentlyContinue
        Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    }
}

# 🧼 Sanitize kundli_api.py (remove emoji/unicode)
$content = Get-Content $scriptPath
$cleaned = $content | Where-Object { $_ -cmatch '^[\x00-\x7F]*$' }
$cleaned | Set-Content $scriptPath -Encoding utf8

# ✅ Ensure __main__ block exists
if ($cleaned -join "`n" -notmatch "if\s+__name__\s*==\s*['""]__main__['""]") {
    Write-Host "⚠️  Adding '__main__' block..."
    Add-Content -Path $scriptPath -Value @"
if __name__ == '__main__':
    print("Starting Kundli Match API...")
    app.run(debug=True, host='0.0.0.0', port=5055)
"@
}

# 🚀 Start Flask server in background
Write-Host "`n🚀 Launching Flask API in background..."
Start-Job -ScriptBlock {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$using:pythonPath $using:scriptPath > $using:logFile 2>&1`"" -NoNewWindow
} | Out-Null

Start-Sleep -Seconds 5

# 🌐 Ping API up to 6 times
$pingSuccess = $false
for ($i = 0; $i -lt 6; $i++) {
    try {
        $null = Invoke-RestMethod -Uri $uri -Method Options -TimeoutSec 3
        $pingSuccess = $true
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $pingSuccess) {
    Write-Host "❌ API did not start after 12 seconds. Check $logFile for issues." -ForegroundColor Red
    if (Test-Path $logFile) { Get-Content $logFile -Tail 40 }
    exit
}

# 📡 Send test request
$payload = @{
    person1 = @{
        name = "Amit"
        birth_date = "1990-01-01"
        birth_time = "12:00:00"
        latitude = 28.6139
        longitude = 77.2090
    }
    person2 = @{
        name = "Anita"
        birth_date = "1992-05-10"
        birth_time = "15:30:00"
        latitude = 19.0760
        longitude = 72.8777
    }
} | ConvertTo-Json -Depth 4

Write-Host "`n📡 Sending test request to $uri ..."
try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $payload -ContentType "application/json"
    Write-Host "✅ Response received!"
    Write-Host "🔮 Guna Score: $($response.guna_score)"
    Write-Host "✅ Verdict: $($response.verdict)"
} catch {
    Write-Host "❌ Request failed: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path $logFile) {
        Write-Host "`n📄 Log output:"
        Get-Content $logFile -Tail 40
    } else {
        Write-Host "⚠️  Log file not found."
    }
}

Write-Host "`n📄 Full log at: $logFile"
