<#
.SYNOPSIS
    Analyzes a PowerShell script for unbalanced braces.
.DESCRIPTION
    Helps debug errors like "Unexpected token '}'" by counting and listing
    all brace locations.
.PARAMETER File
    Path to the PowerShell script to check.
.EXAMPLE
    .\Check-Braces.ps1 -File .\Run-AllHealthChecks.ps1
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$File
)

if (-not (Test-Path $File)) {
    Write-Error "❌ File not found: $File"
    exit 1
}

Write-Host "🧭 Analyzing braces in file: $File`n"

# Load all lines
$lines = Get-Content $File

# Track braces
$openCount = 0
$closeCount = 0

$braceLines = @()

for ($i=0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]

    $openMatches = ([regex]::Matches($line, "\{")).Count
    $closeMatches = ([regex]::Matches($line, "\}")).Count

    if ($openMatches -gt 0 -or $closeMatches -gt 0) {
        $braceLines += [PSCustomObject]@{
            LineNumber = $i + 1
            Opens = $openMatches
            Closes = $closeMatches
            Line = $line.Trim()
        }
    }

    $openCount += $openMatches
    $closeCount += $closeMatches
}

# Print results
Write-Host "📜 Total opening braces: $openCount"
Write-Host "📜 Total closing braces: $closeCount`n"

if ($openCount -eq $closeCount) {
    Write-Host "✅ Braces appear balanced."
} else {
    Write-Warning "⚠️  Braces are UNBALANCED!"
    if ($openCount -gt $closeCount) {
        Write-Warning "   → Missing $($openCount - $closeCount) closing brace(s)"
    } else {
        Write-Warning "   → Missing $($closeCount - $openCount) opening brace(s)"
    }
}

# Print table
Write-Host "`n🔍 Lines with braces:`n"
$braceLines | Format-Table -AutoSize
