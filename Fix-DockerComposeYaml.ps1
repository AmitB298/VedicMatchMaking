$composePath = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$backupPath = "$composePath.bak"

if (-not (Test-Path $composePath)) {
    Write-Error "❌ docker-compose.yml not found at $composePath"
    exit 1
}

# Backup
Copy-Item $composePath $backupPath -Force
Write-Host "📦 Backup saved at $backupPath" -ForegroundColor DarkGray

$lines = Get-Content $composePath
$fixedLines = @()
$insideApiGateway = $false
$portsInjected = $false

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match "^\s*api-gateway:") {
        $insideApiGateway = $true
        $fixedLines += $line
        continue
    }

    if ($insideApiGateway -and $line -match "^\s*ports:\s*$") {
        # Skip old/broken ports block
        $fixedLines += "    ports:"
        $fixedLines += "      - `"3000:3000`""
        $portsInjected = $true

        # Skip original port lines
        while (($i + 1) -lt $lines.Count -and $lines[$i + 1] -match "^\s*-") {
            $i++
        }

        $insideApiGateway = $false
        continue
    }

    if ($insideApiGateway -and $line -match "^\s*\S") {
        # No ports found, inject before exiting api-gateway
        if (-not $portsInjected) {
            $fixedLines += "    ports:"
            $fixedLines += "      - `"3000:3000`""
            $portsInjected = $true
        }
        $insideApiGateway = $false
    }

    $fixedLines += $line
}

# Final fallback: inject if totally missing
if (-not $portsInjected) {
    $injected = $false
    for ($i = 0; $i -lt $fixedLines.Count; $i++) {
        if ($fixedLines[$i] -match "^\s*api-gateway:") {
            $fixedLines = $fixedLines[0..$i] + @(
                "    ports:",
                "      - `"3000:3000`""
            ) + $fixedLines[($i+1)..($fixedLines.Count - 1)]
            $injected = $true
            break
        }
    }
    if ($injected) {
        Write-Host "🛠️ Injected missing ports block for api-gateway" -ForegroundColor Cyan
    }
}

# Save updated file
Set-Content $composePath $fixedLines -Encoding utf8
Write-Host "✅ Fixed docker-compose.yml syntax and port exposure" -ForegroundColor Green

# Restart Docker
Push-Location (Split-Path $composePath)
Write-Host "`n🚀 Restarting backend stack..." -ForegroundColor Cyan
docker compose down
docker compose up -d --build
Pop-Location
