param (
    [Parameter(Mandatory)]
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Validating folder structure at: $ServicePath"
Write-Host "------------------------------------------------------------"

$expectedFiles = @(
    "kundli_service.py",
    "requirements.txt",
    "Dockerfile"
)

$files = Get-ChildItem -Path $ServicePath -File | Select-Object -ExpandProperty Name

Write-Host "📂 Files found:"
$files | ForEach-Object { Write-Host "   - $_" }

$missing = $expectedFiles | Where-Object { $_ -notin $files }
$unexpected = $files | Where-Object { $_ -notin $expectedFiles }

if ($missing.Count -eq 0 -and $unexpected.Count -eq 0) {
    Write-Host "✅ Structure is correct!"
} else {
    if ($missing.Count -gt 0) {
        Write-Host "❌ Missing expected files:"
        $missing | ForEach-Object { Write-Host "   - $_" }
    }
    if ($unexpected.Count -gt 0) {
        Write-Host "⚠️ Unexpected extra files:"
        $unexpected | ForEach-Object { Write-Host "   - $_" }
    }
}

Write-Host "------------------------------------------------------------"
Write-Host "✅ Validation complete!"
Write-Host "------------------------------------------------------------"
