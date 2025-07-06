# Fix-DockerCompose.ps1
Write-Host "`n🔧 Auto-fixing docker-compose.yml for Vedic Matchmaking..." -ForegroundColor Cyan

$yamlPath = ".\docker-compose.yml"

if (-not (Test-Path $yamlPath)) {
    Write-Host "❌ docker-compose.yml not found!" -ForegroundColor Red
    return
}

# Read content
$content = Get-Content $yamlPath

# Remove duplicate container_name definitions (very basic fix)
$seenContainers = @{}
$newLines = @()
$insideService = $false
$currentService = ""

foreach ($line in $content) {
    if ($line.Trim() -match "^(\w+):$" -and $line -notmatch "version|services") {
        $currentService = $matches[1]
        $insideService = $true
    }

    if ($insideService -and $line.Trim().StartsWith("container_name:")) {
        if ($seenContainers.ContainsKey($currentService)) {
            Write-Host "⚠️ Removed duplicate container_name in '$currentService'" -ForegroundColor Yellow
            continue
        } else {
            $seenContainers[$currentService] = $true
        }
    }

    $newLines += $line
}

# Save sanitized YAML
$newLines | Set-Content $yamlPath -Encoding UTF8
Write-Host "✅ docker-compose.yml cleaned and updated." -ForegroundColor Green
