# Fix-RegexInScript.ps1

param (
    [string]$ScriptPath = ".\FixAndDeploy-VedicApp.ps1"
)

Write-Host "🔍 Scanning $ScriptPath for unsafe regex strings..." -ForegroundColor Cyan

if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ Script file not found: $ScriptPath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $ScriptPath -Raw
$lines = $content -split "`n"
$modified = $false

# Regex to detect -match or -notmatch using double quotes and containing unescaped [ or ]
$pattern = '(-notmatch|-match)\s+"([^"]*\[[^"]*\])"'

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match $pattern) {
        $original = $matches[0]
        $regexPart = $matches[2]
        $safeRegex = $regexPart.Replace('"', '\"').Replace("'", "''") # escape inner quotes
        $newLine = $lines[$i] -replace $pattern, "`$1 '$safeRegex'"
        Write-Host "⚠️ Fixing line $($i+1): $lines[$i]" -ForegroundColor Yellow
        Write-Host "➡️  Replaced with     : $newLine" -ForegroundColor Green
        $lines[$i] = $newLine
        $modified = $true
    }
}

if ($modified) {
    $backupPath = "$ScriptPath.bak"
    Copy-Item $ScriptPath $backupPath -Force
    $lines -join "`n" | Set-Content $ScriptPath
    Write-Host "`n✅ Fixes applied! Backup saved as: $backupPath" -ForegroundColor Green
} else {
    Write-Host "✅ No regex issues found. Script is clean." -ForegroundColor Green
}
