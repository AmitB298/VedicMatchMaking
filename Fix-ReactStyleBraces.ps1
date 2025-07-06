<#
.SYNOPSIS
  Fixes JSX style attributes with extra braces in React .tsx files.

.DESCRIPTION
  - Recursively scans .tsx files in given paths.
  - Specifically detects style={{ ... }}} errors (too many closing braces).
  - Fixes them by reducing to style={{ ... }}.
  - Makes .bak backups before editing.
#>

param (
    [Parameter(Mandatory=$true)]
    [string[]]$Paths
)

Write-Host "🛠️  Starting React style fixer script..."

foreach ($path in $Paths) {
    Write-Host "🔎 Scanning: $path"

    $tsxFiles = Get-ChildItem -Path $path -Recurse -Include *.tsx -ErrorAction SilentlyContinue

    foreach ($file in $tsxFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content

        $fixed = $false

        # Regex pattern to detect style prop with extra braces
        $pattern = '(style\s*=\s*\{\{[^}]*\}\})\}'

        if ($content -match $pattern) {
            $fixed = $true
            Write-Host "⚠️  Problem detected in: $($file.FullName)"

            # Replace style={{ ... }}} with style={{ ... }}
            $content = [regex]::Replace($content, $pattern, '$1')

            # Backup original file
            $backupPath = $file.FullName + ".bak"
            Set-Content -Path $backupPath -Value $originalContent -Encoding UTF8
            Write-Host "📦 Backup created: $backupPath"

            # Save fixed file
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Host "✅ Fixed and updated: $($file.FullName)"
        } else {
            Write-Host "✅ No changes needed for: $($file.FullName)"
        }
    }
}

Write-Host "🎯 All done!"
