<#
.SYNOPSIS
    Fixes common JSX style attribute errors in .tsx files.
.DESCRIPTION
    - Removes extra closing braces.
    - Removes unnecessary backslashes before %.
    - Preserves template literals like `${value}%`.
    - Validates braces are balanced.
    - Creates backups of modified files.
#>

param (
    [string[]]$Paths
)

function Fix-Line {
    param([string]$line)

    $originalLine = $line

    # Fix backslash-escaped % (only outside template literals)
    if ($line -notmatch '\$\{.*?\}') {
        $line = $line -replace '\\%', '%'
    }

    # Remove extra closing braces in style props
    # e.g. style={{ width: '100%' }}}
    $line = $line -replace '(style=\{\{.*?\}\})\}', '$1'

    return $line
}

function Validate-Line {
    param([string]$line, [string]$file, [int]$lineNumber)

    # Count { and } inside style prop
    if ($line -match 'style=\{') {
        $openCount = ([regex]::Matches($line, '\{')).Count
        $closeCount = ([regex]::Matches($line, '\}')).Count

        if ($openCount -ne $closeCount) {
            Write-Warning "⚠️ Unbalanced braces in $file at line $lineNumber"
        }
    }
}

function Process-File {
    param([string]$file)

    Write-Host "📝 Processing $file"

    $changed = $false
    $content = Get-Content $file
    $newContent = @()

    for ($i = 0; $i -lt $content.Length; $i++) {
        $line = $content[$i]
        $fixed = Fix-Line -line $line

        if ($line -ne $fixed) {
            Write-Host "✅ Fixed at line $($i+1)"
            $changed = $true
        }

        Validate-Line -line $fixed -file $file -lineNumber ($i+1)
        $newContent += $fixed
    }

    if ($changed) {
        $backupPath = "$file.bak"
        Copy-Item $file $backupPath -Force
        Write-Host "📦 Backup created: $backupPath"

        Set-Content $file $newContent -Force
        Write-Host "✅ Updated: $file"
    } else {
        Write-Host "✅ No changes needed for: $file"
    }
}

# MAIN
foreach ($path in $Paths) {
    Write-Host "🔎 Scanning: $path"
    Get-ChildItem -Path $path -Recurse -Include *.tsx | ForEach-Object {
        Process-File -file $_.FullName
    }
}

Write-Host "🎯 All done!"
