<#
.SYNOPSIS
  Cleans React .tsx files of:
    - Extra closing braces in style attributes
    - Merge conflict markers
.DESCRIPTION
  Use this to stop production build failures due to bad JSX.
.PARAMETER Paths
  One or more root folders to scan.
.EXAMPLE
  .\Fix-ReactStyleBracesAdvanced.ps1 -Paths "src","../services/kundli/src"
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$Paths
)

Write-Host "🛠️  Starting Advanced React JSX fixer..."

foreach ($path in $Paths) {
    Write-Host "🔎 Scanning: $path"
    $tsxFiles = Get-ChildItem -Path $path -Recurse -Include *.tsx -ErrorAction SilentlyContinue

    foreach ($file in $tsxFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        $fixed = $false

        # 1️⃣ Fix extra closing braces in style props
        $patternStyle = '(style\s*=\s*\{\{[^}]*\}\})\}+'  
        $newContent = [regex]::Replace($content, $patternStyle, '$1')

        if ($newContent -ne $content) {
            $content = $newContent
            $fixed = $true
            Write-Host "⚡ Fixed extra braces in style: $($file.FullName)"
        }

        # 2️⃣ Remove merge conflict markers
        $patternConflict = '^(<<<<<<<|=======|>>>>>>>)'
        if ($content -match $patternConflict) {
            $content = [regex]::Replace($content, $patternConflict, '', 'Multiline')
            $fixed = $true
            Write-Host "⚡ Removed merge conflict markers in: $($file.FullName)"
        }

        # 3️⃣ Save if changed
        if ($fixed) {
            $backupPath = $file.FullName + ".bak"
            Set-Content -Path $backupPath -Value $originalContent -Encoding UTF8
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Host "✅ Updated: $($file.FullName)"
            Write-Host "📦 Backup created at: $backupPath"
        } else {
            Write-Host "✅ No changes needed for: $($file.FullName)"
        }
    }
}

Write-Host "🎯 All done! Ready for production."
