$ErrorActionPreference = "Stop"
$targetFile = "Fix-ApiGateway-SocketIO.ps1"
$backupFile = "$targetFile.bak"

if (-not (Test-Path $targetFile)) {
    Write-Error "❌ Target file $targetFile not found."
    exit 1
}

Write-Host "🔍 Scanning $targetFile for malformed hash literal..." -ForegroundColor Cyan
Copy-Item $targetFile $backupFile -Force
Write-Host "📦 Backup saved to $backupFile" -ForegroundColor Yellow

$content = Get-Content $targetFile
$fixed = @()
$insideDependencies = $false

foreach ($line in $content) {
    $trimmed = $line.Trim()

    if ($trimmed -match '^\s*dependencies\s*=\s*@\{\s*$') {
        $insideDependencies = $true
        $fixed += '        $dependencies = @{}'
        continue
    }

    if ($insideDependencies -and $trimmed -match '^([a-zA-Z0-9.\-+]+)\s*=\s*"([^"]+)"$') {
        $key = $matches[1]
        $val = $matches[2]
        $fixed += "        `\$dependencies.Add(`"$key`", `"$val`")"
        continue
    }

    if ($insideDependencies -and $trimmed -eq "}") {
        $insideDependencies = $false
        $fixed += '        $package.dependencies = $dependencies'
        continue
    }

    $fixed += $line
}

# Ensure we don’t leave the hash block open
if ($insideDependencies) {
    $fixed += '        $package.dependencies = $dependencies'
    $insideDependencies = $false
}

Set-Content -Path $targetFile -Value $fixed -Encoding utf8
Write-Host "✅ Fixed malformed hash literals in $targetFile" -ForegroundColor Green
