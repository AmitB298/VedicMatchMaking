# === CONFIG ===
$expectedService = "matchmaking-app-backend-api-gateway-1"
$expectedPort = 3000
$expectedPath = "/socket.io/?EIO=4&transport=polling"
$dockerPs = docker ps --format "{{.Names}}"
$knownPorts = @(3000, 27017, 6379, 5672, 15672)

Write-Host "🔎 Scanning known service ports for active Socket.IO endpoints..." -ForegroundColor Cyan

$found = $false
foreach ($port in $knownPorts) {
    try {
        $url = "http://localhost:$port$expectedPath"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 400) {
            Write-Host "✅ Detected Socket.IO-style response at port $port" -ForegroundColor Green
            if ($port -ne $expectedPort) {
                Write-Warning "⚠️ Socket.IO is responding on port $port (unexpected)"
                Write-Host "📦 Possibly misconfigured container or port mapping." -ForegroundColor Yellow
            }
            $found = $true
            break
        }
    } catch {
        Write-Host "❌ Port $port not responding to Socket.IO probe." -ForegroundColor DarkGray
    }
}

if (-not $found) {
    Write-Warning "`n❌ Socket.IO is NOT responding on expected port ($expectedPort). Trying to restart $expectedService..."
    docker compose restart $expectedService | Out-Null
    Start-Sleep -Seconds 10

    try {
        $retryUrl = "http://localhost:$expectedPort$expectedPath"
        $retryResponse = Invoke-WebRequest -Uri $retryUrl -UseBasicParsing -TimeoutSec 5
        if ($retryResponse.StatusCode -eq 200 -or $retryResponse.StatusCode -eq 400) {
            Write-Host "✅ Socket.IO came online on port $expectedPort after restart." -ForegroundColor Green
        } else {
            Write-Error "❌ Still no valid response from $expectedService after restart."
        }
    } catch {
        Write-Error "❌ Socket.IO unreachable after restart. Check logs or port binding."
    }
} else {
    Write-Host "`n🎉 Socket.IO appears correctly configured." -ForegroundColor Green
}
