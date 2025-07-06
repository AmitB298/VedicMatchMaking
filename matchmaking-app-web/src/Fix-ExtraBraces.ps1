param (
    [Parameter(Mandatory = $true)]
    [string[]]$Paths
)

Write-Host "🛠️  Starting Extra JSX Braces Auto-Fixer..." -ForegroundColor Cyan

foreach ($Path in $Paths) {
    Write-Host "🔎 Scanning: $Path" -ForegroundColor Yellow

    Get-ChildItem -Path $Path -Recurse -Include *.tsx | ForEach-Object {
        $File = $_.FullName
        $Content = Get-Content $File -Raw

        $Original = $Content
        $Lines = $Content -split "`n"
        $FixedLines = @()
        $Modified = $false

        for ($i = 0; $i -lt $Lines.Length; $i++) {
            $Line = $Lines[$i]
            $FixedLine = $Line

            # Match style={{ ... }}} or more
            if ($FixedLine -match 'style\s*=\s*\{\{.*\}\s*\}+\s*') {
                # Replace all excessive closing braces at end with exactly two
                $FixedLine = [regex]::Replace($FixedLine, '\}\s*\}+\s*', '}}')
                if ($FixedLine -ne $Line) {
                    Write-Host "⚡ Fixing extra braces at line $($i+1) in $File" -ForegroundColor Green
                    $Modified = $true
                }
            }

            $FixedLines += $FixedLine
        }

        if ($Modified) {
            $Backup = "$File.bak"
            Copy-Item -Path $File -Destination $Backup -Force
            $FixedLines | Set-Content -Path $File -Encoding UTF8
            Write-Host "✅ Updated and backed up: $File" -ForegroundColor Green
        }
        else {
            Write-Host "✅ No issues found in: $File" -ForegroundColor DarkGray
        }
    }
}

Write-Host "🎯 All done! Ready for production." -ForegroundColor Cyan
