param (
    [Parameter(Mandatory = $true)]
    [string[]]$Paths
)

Write-Host "🛠️  Starting Advanced React JSX fixer..."

foreach ($path in $Paths) {
    Write-Host "🔎 Scanning: $path"

    $tsxFiles = Get-ChildItem -Path $path -Recurse -Include *.tsx -ErrorAction SilentlyContinue

    foreach ($file in $tsxFiles) {
        $lines = Get-Content $file.FullName
        $original = $lines.Clone()
        $fixed = $false
        $newLines = @()

        foreach ($line in $lines) {
            $newLine = $line

            if (![string]::IsNullOrWhiteSpace($newLine)) {
                # Fix style={{...}}} -> style={{...}}
                if ($newLine -match 'style\s*=\s*\{\{.*\}\}\}') {
                    $old = $newLine
                    $newLine = $newLine -replace '\}\}\}+', '}}'
                    if ($newLine -ne $old) {
                        Write-Host "⚡ Fixed extra braces in: $($file.FullName)"
                        $fixed = $true
                    }
                }

                # Remove merge conflict markers
                if ($newLine -match '^(<<<<<<<|=======|>>>>>>>)') {
                    Write-Host "⚡ Removed merge conflict marker in: $($file.FullName)"
                    $newLine = ''
                    $fixed = $true
                }
            }

            $newLines += $newLine
        }

        if ($fixed) {
            $backup = "$($file.FullName).bak"
            Set-Content -Path $backup -Value $original
            Set-Content -Path $file.FullName -Value $newLines
            Write-Host "✅ Updated: $($file.FullName)"
            Write-Host "📦 Backup created: $backup"
        }
        else {
            Write-Host "✅ No changes needed for: $($file.FullName)"
        }
    }
}

Write-Host "🎯 All done! Ready for production."
