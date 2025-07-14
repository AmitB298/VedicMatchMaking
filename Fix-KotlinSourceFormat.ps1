param (
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Source File Import & Package Normalizer"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $SourceRoot)) {
    Write-Error "❌ ERROR: Source root not found at path: $SourceRoot"
    exit 1
}

$files = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt

if (-Not $files) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName

    $packageLine = $content | Where-Object { $_ -match '^\s*package\s+' } | Select-Object -First 1
    if (-not $packageLine) {
        Write-Warning "⚠️ No package declaration in $($file.FullName). Skipping."
        continue
    }

    # Collect all imports
    $importLines = $content | Where-Object { $_ -match '^\s*import\s+' } | Sort-Object -Unique

    # Collect all OptIn annotations
    $optInLines = $content | Where-Object { $_ -match '^\s*@OptIn' }

    # Remove package, imports, OptIn from body
    $bodyLines = $content | Where-Object {
        ($_ -notmatch '^\s*package\s+') -and
        ($_ -notmatch '^\s*import\s+') -and
        ($_ -notmatch '^\s*@OptIn')
    }

    # Build cleaned content
    $newContent = @()
    $newContent += $packageLine
    $newContent += ""
    if ($importLines.Count -gt 0) {
        $newContent += $importLines
        $newContent += ""
    }
    if ($optInLines.Count -gt 0) {
        $newContent += $optInLines
        $newContent += ""
    }
    $newContent += $bodyLines

    # Save
    $newContent | Set-Content $file.FullName -Encoding UTF8
    Write-Host "✅ Normalized: $($file.FullName)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Your Kotlin sources are now normalized."
Write-Host "   Next: Run './gradlew clean assembleDebug'"
Write-Host "------------------------------------------------------------"
