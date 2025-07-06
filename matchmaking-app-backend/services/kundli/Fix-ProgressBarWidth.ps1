# .SYNOPSIS
#   Hard-replaces broken style lines in ProgressBar.tsx

param(
    [string]$Path = "."
)

Write-Host "🔍 Looking for ProgressBar.tsx in $Path"

$progressBar = Get-ChildItem -Path $Path -Recurse -Filter "progress*.tsx"

if (-not $progressBar) {
    Write-Host "⚠️ No ProgressBar.tsx found."
    exit
}

foreach ($file in $progressBar) {
    Write-Host "📝 Fixing: $($file.FullName)"

    $content = Get-Content $file.FullName

    # Replace the broken line
    $fixedContent = $content -replace 'style=\{\s*.*\\%.*\}', 'style={{ width: `${value}%` }}'

    # Backup
    $backup = $file.FullName + ".bak"
    Copy-Item $file.FullName $backup -Force
    Write-Host "📦 Backup saved: $backup"

    # Write new
    $fixedContent | Set-Content $file.FullName -Encoding UTF8
    Write-Host "✅ Fixed and saved: $($file.FullName)"
}

Write-Host "🎯 Done!"
