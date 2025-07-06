<#
.SYNOPSIS
  Checks a PowerShell file for unbalanced braces.
.DESCRIPTION
  - Counts { and }
  - Lists lines with braces
  - Suggests potential extra lines to remove
#>

param(
    [string]$File
)

if (-not (Test-Path $File)) {
    Write-Error "❌ File not found: $File"
    exit 1
}

Write-Host "🧭 Analyzing braces in file: $File`n"

# Load lines
$lines = Get-Content $File

# Count braces
$totalOpen  = ($lines | Select-String '{').Count
$totalClose = ($lines | Select-String '}').Count

Write-Host "📜 Total opening braces: $totalOpen"
Write-Host "📜 Total closing braces: $totalClose`n"

# Check balance
if ($totalOpen -eq $totalClose) {
    Write-Host "✅ Braces appear balanced." -ForegroundColor Green
} elseif ($totalOpen -gt $totalClose) {
    Write-Warning "⚠️ More { than }. You may be missing closing braces."
} else {
    Write-Warning "⚠️ More } than {. You have extra closing braces!"
}

# Show all lines with braces
Write-Host "`n🔍 Lines with braces:`n"
$i = 1
foreach ($line in $lines) {
    if ($line -match '[{}]') {
        Write-Host "$i`t$line"
    }
    $i++
}

# Suggest lines with single }
$braceLines = @()
$i = 1
foreach ($line in $lines) {
    if ($line.Trim() -eq '}') {
        $braceLines += $i
    }
    $i++
}

if ($braceLines.Count -gt 0) {
    Write-Host "`n🧩 Lines with only '}':"
    $braceLines | ForEach-Object { Write-Host "  - Line $_" }

    Write-Warning "`n⚠️ Suggestion: Check these lines for redundant closing braces."
} else {
    Write-Host "`n✅ No lines with only '}' found."
}
