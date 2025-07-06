<#
.SYNOPSIS
    Cleans server.js to enforce process.env.MONGODB_URI with no local fallback.

.DESCRIPTION
    - Reads server.js
    - Finds lines with fallback to local mongodb://localhost
    - Replaces with clean single line using env var
    - Creates server.js.bak backup

.EXAMPLE
    .\Clean-ServerJsMongoUri.ps1
#>

param(
    [string]$ServerPath = ".\server.js"
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking server.js MongoDB URI Cleaner" -ForegroundColor Cyan
Write-Host "---------------------------------------------------------------"

# 1️⃣ Check if server.js exists
if (!(Test-Path $ServerPath)) {
    Write-Host "❌ ERROR: Cannot find server.js at path '$ServerPath'" -ForegroundColor Red
    exit 1
}

# 2️⃣ Load content
$lines = Get-Content $ServerPath
$originalLines = $lines.Clone()

# 3️⃣ Detect problematic lines
$foundBadLines = $false
$cleanedLines = @()

foreach ($line in $lines) {
    if ($line -match 'process\.env\.MONGODB_URI\s*\|\|') {
        Write-Host "⚠️  Found line with fallback:" -ForegroundColor Yellow
        Write-Host "   $line" -ForegroundColor Yellow
        $foundBadLines = $true
        $cleanedLines += 'const uri = process.env.MONGODB_URI;'
    }
    elseif ($line -match 'mongodb(\+srv)?:\/\/') {
        if ($line -notmatch 'process\.env\.MONGODB_URI') {
            Write-Host "⚠️  Found hard-coded MongoDB URI:" -ForegroundColor Yellow
            Write-Host "   $line" -ForegroundColor Yellow
            $foundBadLines = $true
            $cleanedLines += 'const uri = process.env.MONGODB_URI;'
        }
        else {
            $cleanedLines += $line
        }
    }
    else {
        $cleanedLines += $line
    }
}

if (-not $foundBadLines) {
    Write-Host ""
    Write-Host "✅ No hard-coded fallback or wrong URIs found." -ForegroundColor Green
    Write-Host "✅ Your server.js is already clean!" -ForegroundColor Green
    exit 0
}

# 4️⃣ Confirm replacement
Write-Host ""
$choice = Read-Host "👉 Do you want to remove all fallbacks and enforce clean process.env.MONGODB_URI? (Y/N)"
if ($choice -notmatch '^[Yy]$') {
    Write-Host "❌ Aborted. No changes made." -ForegroundColor Red
    exit 1
}

# 5️⃣ Backup
$backupPath = "$ServerPath.bak"
Set-Content $backupPath $originalLines
Write-Host ""
Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Green

# 6️⃣ Write cleaned file
Set-Content $ServerPath $cleanedLines
Write-Host "✅ server.js cleaned and updated!" -ForegroundColor Green
Write-Host ""
Write-Host "✨ Done! Your server.js now uses ONLY process.env.MONGODB_URI" -ForegroundColor Cyan
