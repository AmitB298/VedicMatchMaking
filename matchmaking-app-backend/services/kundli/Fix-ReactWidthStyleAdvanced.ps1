<#
.SYNOPSIS
  Smarter fix for broken width style lines in .tsx files.

.DESCRIPTION
  Finds any 'style={{ width: ... }}' that doesn't use proper template string
  and rewrites it to: style={{ width: `${value}%` }}

.PARAMETER Path
  Root folder to search

.EXAMPLE
  .\Fix-ReactWidthStyleAdvanced.ps1 -Path "src"
#>

param(
    [string]$Path = "."
)

Write-Host "🔍 Advanced scan for .tsx files in: $Path"

$tsxFiles = Get-ChildItem -Path $Path -Recurse -Include *.tsx

if (-not $tsxFiles) {
    Write-Host "⚠️ No .tsx files found."
    exit
}

foreach ($file in $tsxFiles) {
    Write-Host "📝 Checking: $($file.FullName)"

    $lines = Get-Content $file.FullName
    $changed = $false
    $newLines = @()

    foreach ($line in $lines) {
        # Match any bad width style that is *not* already using `${}`
        if ($line -match 'style\s*=\s*{.*width.*%.*}') {
            if ($line -notmatch '`\$\{.*\}`') {
                Write-Host "❌ Found invalid width style:"
                Write-Host $line -ForegroundColor Red

                # Replace it with correct style
                $fixedLine = $line -replace 'style\s*=\s*{.*}', 'style={{ width: `${value}%` }}'

                Write-Host "✅ Fixed to:"
                Write-Host $fixedLine -ForegroundColor Green

                $newLines += $fixedLine
                $changed = $true
            }
            else {
                $newLines += $line
            }
        }
        else {
            $newLines += $line
        }
    }

    if ($changed) {
        $backupFile = $file.FullName + ".bak"
        Copy-Item $file.FullName $backupFile -Force
        Write-Host "📦 Backup saved to: $backupFile"

        $newLines | Set-Content $file.FullName -Encoding UTF8
        Write-Host "✅ Updated file written: $($file.FullName)"
    }
    else {
        Write-Host "✅ No issues found in this file."
    }

    Write-Host ""
}

Write-Host "🎯 Advanced scan and fix complete!"
