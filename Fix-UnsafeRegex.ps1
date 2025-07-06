param (
    [string]$ScriptPath = ".\FixAndDeploy-VedicApp.ps1"
)

Write-Host "🔍 Scanning for unsafe regex in: $ScriptPath" -ForegroundColor Cyan

if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ File not found: $ScriptPath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $ScriptPath -Raw
$lines = $content -split "`n"
$modified = $false

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]

    # Detect lines with -match or -notmatch and double-quoted strings that include [ or ]
    if ($line -match '(-notmatch|-match)\s+"([^"]*\[[^"]*\])"') {
        $original = $matches[0]
        $regexRaw = $matches[2]

        # Convert to safe regex in single quotes
        $regexFixed = $regexRaw.Replace("'", "''")  # Escape any single quotes
        $fixedLine = $line -replace '(-notmatch|-match)\s+"([^"]*\[[^"]*\])"', "`$1 '$regexFixed'"

        Write-Host "⚠️ Fixing Line $($i + 1):" -ForegroundColor Yellow
        Write-Host "   Before: $line" -ForegroundColor DarkGray
        Write-Host "   After : $fixedLine" -ForegroundColor Green

        $lines[$i] = $fixedLine
        $modified = $true
    }
}

if ($modified) {
    $backupPath = "$ScriptPath.bak"
    Copy-Item $ScriptPath $backupPath -Force
    $lines -join "`n" | Set-Content $ScriptPath
    Write-Host "✅ Fixes applied! Backup created at: $backupPath" -ForegroundColor Green
} else {
    Write-Host "✅ No unsafe regex detected. Script is clean." -ForegroundColor Green
}
