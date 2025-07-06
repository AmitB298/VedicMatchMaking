<#
.SYNOPSIS
  Diagnoses and fixes hard-coded MongoDB URIs in .env and server.js

.DESCRIPTION
  - Scans .env for invalid cluster hostnames
  - Scans all .js files for hard-coded mongodb+srv:// URIs
  - Reports exact lines
  - Offers to replace them with process.env.MONGODB_URI
  - Creates .bak backups before editing

.EXAMPLE
  .\Check-And-Fix-MongoUri.ps1
#>

param (
    [string]$BackendPath = ".\matchmaking-app-backend"
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking Comprehensive MongoDB URI Diagnostic & Fixer" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------"

# 1️⃣ Check .env
$envPath = Join-Path $BackendPath ".env"
if (!(Test-Path $envPath)) {
    Write-Host "❌ ERROR: .env file not found at $envPath" -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "✅ Checking .env file at $envPath" -ForegroundColor Green
    $envLines = Get-Content $envPath
    $uriLine = $envLines | Where-Object { $_ -match '^MONGODB_URI\s*=' }

    if ($null -eq $uriLine) {
        Write-Host "⚠️  MONGODB_URI is missing in .env!" -ForegroundColor Yellow
    } else {
        $uriValue = $uriLine -replace '^MONGODB_URI\s*=', ''
        Write-Host "   MONGODB_URI: $uriValue"

        if ($uriValue -match 'fitspherecluster') {
            Write-Host ""
            Write-Host "❗️ WARNING: Detected invalid cluster host 'fitspherecluster' in .env" -ForegroundColor Red
            $fixEnv = Read-Host "👉 Do you want to update MONGODB_URI now? (Y/N)"
            if ($fixEnv -match '^[Yy]$') {
                $newUri = Read-Host "👉 Enter your correct MongoDB Atlas URI (must start with mongodb+srv://)"
                $fixedLines = $envLines | ForEach-Object {
                    if ($_ -match '^MONGODB_URI\s*=') { "MONGODB_URI=$newUri" } else { $_ }
                }
                Copy-Item $envPath "$envPath.bak" -Force
                Set-Content $envPath $fixedLines
                Write-Host "✅ .env updated and backup created at .env.bak" -ForegroundColor Green
            }
        } else {
            Write-Host "✅ .env MONGODB_URI looks okay." -ForegroundColor Green
        }
    }
}

# 2️⃣ Check .js files for hard-coded URIs
Write-Host ""
Write-Host "✅ Scanning JavaScript files for hard-coded MongoDB URIs..." -ForegroundColor Green

$jsFiles = Get-ChildItem -Path $BackendPath -Recurse -Include *.js
$hardCodedLines = @()

foreach ($file in $jsFiles) {
    $lines = Get-Content $file.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'mongodb(\+srv)?:\/\/') {
            $hardCodedLines += [PSCustomObject]@{
                File = $file.FullName
                LineNumber = $i + 1
                Content = $lines[$i]
            }
        }
    }
}

if ($hardCodedLines.Count -eq 0) {
    Write-Host "✅ No hard-coded MongoDB URIs found in JS files!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Found hard-coded MongoDB URIs:" -ForegroundColor Yellow
    foreach ($hit in $hardCodedLines) {
        Write-Host "   File: $($hit.File)"
        Write-Host "   Line $($hit.LineNumber): $($hit.Content)"
        Write-Host ""
    }

    $fixJs = Read-Host "👉 Do you want to auto-fix these lines to use process.env.MONGODB_URI? (Y/N)"
    if ($fixJs -match '^[Yy]$') {
        foreach ($group in $hardCodedLines | Group-Object File) {
            $filePath = $group.Name
            $fileLines = Get-Content $filePath
            $original = $fileLines.Clone()

            foreach ($line in $group.Group) {
                $fileLines[$line.LineNumber - 1] = 'const uri = process.env.MONGODB_URI;'
            }

            Copy-Item $filePath "$filePath.bak" -Force
            Set-Content $filePath $fileLines
            Write-Host "✅ Fixed $filePath and created $filePath.bak" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "✨ Done! Comprehensive check and fix complete." -ForegroundColor Cyan
