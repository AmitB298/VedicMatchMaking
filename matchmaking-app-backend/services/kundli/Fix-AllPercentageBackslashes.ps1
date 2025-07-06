<#
.SYNOPSIS
  Fix all occurrences of style={{ width: \\%\\ }} to valid JSX style
.DESCRIPTION
  Replaces invalid double-backslash percentage with template literal
.EXAMPLE
  .\Fix-AllPercentageBackslashes.ps1 -Path "src/components"
#>

param(
    [string]$Path = "."
)

Write-Host "🔍 Searching .tsx files in: $Path"

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
        if ($line -match 'style\s*=\s*{\s*\\\\%\\\\}') {
            Write-Host "❌ Found invalid percentage style:"
            Write-Host $line -ForegroundColor Red

            $fixedLine = $line -replace 'style\s*=\s*{\s*\\\\%\\\\}', 'style={{ width: `${value}%` }}'
            Write-Host "✅ Fixed to:"
            Write-Host $fixedLine -ForegroundColor Green

            $newLines += $fixedLine
            $changed = $true
        }
        else {
            $newLines += $line
        }
    }

    if ($changed) {
        $backupFile = $file.FullName + ".bak"
        Copy-Item $file.FullName $backupFile -Force
        Write-Host "📦 Backup saved: $backupFile"

        $newLines | Set-Content $file.FullName -Encoding UTF8
        Write-Host "✅ Updated file written: $($file.FullName)"
    }
    else {
        Write-Host "✅ No issues found in this file."
    }

    Write-Host ""
}

Write-Host "🎯 Scan and fix complete!"
