<#
.SYNOPSIS
  Automatically fix invalid style={{ width: \\%\ }} in React .tsx files.
.DESCRIPTION
  Replaces invalid backslash-escaped width style with valid CSS.
.PARAMETER Path
  Root folder to search for .tsx files.
.EXAMPLE
  .\Fix-ProgressBarWidthEscape.ps1 -Path "src"
#>

param(
    [string]$Path = "."
)

Write-Host "🔎 Scanning for .tsx files in: $Path"

# Find all .tsx files
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
        # This regex detects the broken style with \\%\\ or similar backslash mess
        if ($line -match 'style\s*=\s*{\s*.*?\\+%\\+.*?}') {
            Write-Host "❌ Found invalid style in:"
            Write-Host $line -ForegroundColor Red

            # Replace with static 100% width
            $fixedLine = $line -replace 'style\s*=\s*{\s*.*?\\+%\\+.*?}', 'style={{ width: ''100%'' }}'

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
        # Backup before overwrite
        $backupFile = $file.FullName + ".bak"
        Copy-Item $file.FullName $backupFile -Force
        Write-Host "📦 Backup saved to: $backupFile"

        # Write fixed file
        $newLines | Set-Content $file.FullName -Encoding UTF8
        Write-Host "✅ Updated file written: $($file.FullName)"
    }
    else {
        Write-Host "✅ No issues found in this file."
    }

    Write-Host ""
}

Write-Host "🎯 Scan and fix complete!"
