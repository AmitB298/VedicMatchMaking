param(
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Import Cleanup & Restructurer"
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
    $lines = Get-Content $file.FullName
    $packageLine = $lines | Where-Object { $_ -match '^package ' }
    $importLines = $lines | Where-Object { $_ -match '^import ' }
    $otherLines = $lines | Where-Object { ($_ -notmatch '^package ') -and ($_ -notmatch '^import ') }

    # Reconstruct file with package, imports, then other content
    $newContent = @()
    if ($packageLine) { $newContent += $packageLine }
    if ($importLines) { $newContent += $importLines }
    $newContent += ""
    $newContent += $otherLines

    $newContent | Set-Content $file.FullName

    Write-Host "✅ Cleaned imports: $($file.Name)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
