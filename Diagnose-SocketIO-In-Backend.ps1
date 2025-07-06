# Patch-DockerCompose-SocketIO.ps1

$composeFile = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$serviceName = "api-gateway"
$expectedPort = "3000:3000"

Write-Host "📦 Checking docker-compose.yml for API Gateway port mapping..." -ForegroundColor Cyan
$lines = Get-Content $composeFile
$index = ($lines | Select-String -Pattern "^\s*$serviceName\s*:" | Select-Object -First 1).LineNumber

if ($index -eq $null) {
    Write-Error "❌ API Gateway service not found in docker-compose.yml"
    return
}

$portMapped = $false
for ($i = $index; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^\s*ports\s*:") {
        # Already has ports
        if ($lines[$i + 1] -match "$expectedPort") {
            $portMapped = $true
            break
        } else {
            $lines = $lines[0..$i] + "      - ""$expectedPort""" + $lines[($i+1)..($lines.Count - 1)]
            $portMapped = $true
            break
        }
    }
    if ($lines[$i] -match "^\s*[a-zA-Z0-9_-]+\s*:") { break }
}

if (-not $portMapped) {
    $insertAt = $index + 1
    $lines = $lines[0..$insertAt] + @("    ports:", "      - ""$expectedPort""") + $lines[($insertAt + 1)..($lines.Count - 1)]
}

Set-Content $composeFile $lines
Write-Host "✅ docker-compose.yml patched with port $expectedPort" -ForegroundColor Green
