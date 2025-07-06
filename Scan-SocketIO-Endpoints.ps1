$ErrorActionPreference = "Stop"
Write-Host "`n🔎 Scanning Docker containers for active Socket.IO endpoints..." -ForegroundColor Cyan

# Step 1: Get all running containers and their exposed ports
$containers = docker ps --format '{{.Names}} {{.Ports}}'

if (-not $containers) {
    Write-Host "❌ No running containers found." -ForegroundColor Red
    exit 1
}

# Step 2: Parse ports and try /socket.io
$found = $false

foreach ($line in $containers) {
    if ($line -match '^(?<name>\S+)\s+(?<ports>.+)$') {
        $name = $Matches['name']
        $ports = $Matches['ports'] -split ','

        foreach ($port in $ports) {
            if ($port -match '0.0.0.0:(\d+)->') {
                $externalPort = $Matches[1]
                $url = "http://localhost:$externalPort/socket.io/?EIO=4&transport=polling"

                try {
                    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
                    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 400) {
                        Write-Host "✅ Socket.IO endpoint found!" -ForegroundColor Green
                        Write-Host "📦 Container: $name" -ForegroundColor Gray
                        Write-Host "🌐 URL: $url`n" -ForegroundColor Blue
                        $found = $true
                        break
                    }
                } catch {
                    Write-Host "⚠️ $url - Not responding (${name})" -ForegroundColor DarkYellow
                }
            }
        }

        if ($found) { break }
    }
}

if (-not $found) {
    Write-Host "`n❌ No active Socket.IO endpoint found on any running container." -ForegroundColor Red
    Write-Host "🔧 Please ensure that one of your services exposes /socket.io via a valid port." -ForegroundColor Yellow
    Write-Host "💡 Hint: The backend must initialize socket.io like: io = require('socket.io')(server)" -ForegroundColor DarkGray
}
