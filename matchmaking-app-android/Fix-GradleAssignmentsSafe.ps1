<#
.SYNOPSIS
    Safely fixes deprecated Gradle Groovy DSL assignments in build.gradle
.DESCRIPTION
    Converts 'prop value' to 'prop = value' ONLY in android-like blocks.
    Leaves plugins {} untouched.
.PARAMETER FilePath
    Path to the Gradle build file to fix.
.EXAMPLE
    ./Fix-GradleAssignmentsSafe.ps1 -FilePath .\app\build.gradle
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Advanced Gradle Groovy DSL Fixer (Safe, Context-Aware)"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $FilePath)) {
    Write-Error "❌ ERROR: File not found: $FilePath"
    exit 1
}

# Read all lines
$lines = Get-Content -Path $FilePath -Raw | Out-String | Select-String ".*" -AllMatches | % { $_.Matches } | % { $_.Value }

# Block tracking
$insideBlockStack = @()
$fixedLines = @()

foreach ($line in $lines) {
    $trimmed = $line.Trim()

    # Track entering blocks
    if ($trimmed -match '^\s*(\w+)\s*\{\s*$') {
        $blockName = $Matches[1]
        $insideBlockStack += $blockName
        $fixedLines += $line
        continue
    }

    # Track exiting blocks
    if ($trimmed -eq '}') {
        if ($insideBlockStack.Count -gt 0) {
            $insideBlockStack = $insideBlockStack[0..($insideBlockStack.Count - 2)]
        }
        $fixedLines += $line
        continue
    }

    # Determine if we're in a fixable block
    $insideFixableBlock = $false
    foreach ($b in $insideBlockStack) {
        if ($b -in @('android','defaultConfig','buildTypes','compileOptions','kotlinOptions','composeOptions')) {
            $insideFixableBlock = $true
            break
        }
    }

    if ($insideFixableBlock) {
        # Only replace property declarations, but skip lines already using '='
        if ($line -match '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[^\=]') {
            $fixedLine = $line -replace '^(\s*[\w]+)\s+', '$1 = '
            $fixedLines += $fixedLine
            continue
        }
    }

    # Else keep line as is
    $fixedLines += $line
}

# Backup first
$backupPath = "$FilePath.bak"
Copy-Item $FilePath $backupPath -Force
Write-Host "✅ Backup created at: $backupPath"

# Write back
Set-Content -Path $FilePath -Value $fixedLines -Encoding UTF8

Write-Host "✅ Fix applied successfully to: $FilePath"
Write-Host "------------------------------------------------------------"
