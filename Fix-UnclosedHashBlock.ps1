$target = "Fix-ApiGateway-SocketIO.ps1"
$backup = "$target.bak2"

Write-Host "🔧 Fixing unclosed hash blocks in $target..." -ForegroundColor Cyan

if (-not (Test-Path $target)) {
    Write-Error "❌ $target not found."
    exit 1
}

# Backup before rewrite
Copy-Item $target $backup -Force
Write-Host "📦 Backup created at $backup"

$content = Get-Content $target
$output = @()
$openBraces = 0

foreach ($line in $content) {
    $trimmed = $line.Trim()

    if ($trimmed -match '=\s*@\{\s*$') {
        $openBraces += 1
    }

    if ($trimmed -eq "}") {
        $openBraces -= 1
    }

    $output += $line
}

# If still open, auto-close
if ($openBraces -gt 0) {
    for ($i = 0; $i -lt $openBraces; $i++) {
        $output += "}"
    }
    Write-Host "✅ Injected $openBraces missing closing brace(s)." -ForegroundColor Green
} elseif ($openBraces -lt 0) {
    Write-Warning "⚠️ More closing braces than expected."
} else {
    Write-Host "✅ Braces are already balanced." -ForegroundColor Yellow
}

Set-Content $target -Value $output -Encoding utf8
Write-Host "✅ $target cleaned and saved." -ForegroundColor Green
