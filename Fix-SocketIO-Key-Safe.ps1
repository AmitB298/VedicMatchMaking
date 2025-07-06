param (
    [string]$ScriptPath = "Fix-ApiGateway-SocketIO.ps1"
)

if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ Error: File '$ScriptPath' not found." -ForegroundColor Red
    exit 1
}

$backupPath = "$ScriptPath.bak"
Copy-Item $ScriptPath $backupPath -Force
Write-Host "📦 Backup created at $backupPath"

$content = Get-Content $ScriptPath -Raw

# Match keys like: socket.io = "..." (unquoted)
$pattern = '(?m)^\s*(socket\.io)\s*=\s*"([^"]+)"'

if ($content -match $pattern) {
    $fixed = $content -replace $pattern, '    "socket.io" = "$2"'
    Set-Content $ScriptPath -Value $fixed -Encoding utf8
    Write-Host "✅ Fixed unquoted 'socket.io' key in $ScriptPath" -ForegroundColor Green
} else {
    Write-Host "✅ No unquoted 'socket.io' keys found. File is already clean." -ForegroundColor Yellow
}
