param (
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Import & Package Structuring Fixer"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $SourceRoot)) {
    Write-Error "❌ ERROR: Source root not found at path: $SourceRoot"
    exit 1
}

$ktFiles = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt
if (-Not $ktFiles) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $ktFiles) {
    Write-Host "🔎 Processing $($file.FullName)"

    $lines = Get-Content $file.FullName
    if ($lines.Count -eq 0) {
        Write-Host "⚠️ Empty file: $($file.Name)"
        continue
    }

    $packageLine = $null
    $imports = @()
    $code = @()
    $seenImports = @{}

    $hasExperimentalApi = $false
    $hasOptInFileHeader = $false

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        if ($trimmed -match '^@file:OptIn\(.*ExperimentalMaterial3Api') {
            $hasOptInFileHeader = $true
        }

        if ($trimmed -match 'ExperimentalMaterial3Api') {
            $hasExperimentalApi = $true
        }

        if ($trimmed -like 'package *') {
            $packageLine = $trimmed
            continue
        }

        if ($trimmed -like 'import *') {
            if (-not $seenImports.ContainsKey($trimmed)) {
                $imports += $trimmed
                $seenImports[$trimmed] = $true
            }
            continue
        }

        if ($trimmed -ne '') {
            $code += $trimmed
        }
    }

    if (-Not $packageLine) {
        Write-Warning "⚠️ No package declaration in $($file.Name). Skipping."
        continue
    }

    # Compose fixed content
    $newContent = @()
    $newContent += $packageLine
    $newContent += ""
    $newContent += $imports | Sort-Object
    $newContent += ""

    if ($hasExperimentalApi -and -not $hasOptInFileHeader) {
        $newContent += '@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)'
        $newContent += ""
        Write-Host "✅ Added @file:OptIn to $($file.Name)"
    }

    $newContent += $code

    $newContent | Set-Content $file.FullName -Encoding utf8
    Write-Host "✅ Fixed: $($file.Name)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
