param(
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Import Cleanup & Restructurer"
Write-Host "------------------------------------------------------------"

if (-not (Test-Path $SourceRoot)) {
    Write-Error "❌ ERROR: Source root not found at path: $SourceRoot"
    exit 1
}

# Get all .kt files
$files = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt

if (-not $files) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $files) {
    $lines = Get-Content $file.FullName

    if (-not $lines) {
        continue
    }

    # Detect package declaration (should be line 1)
    $packageLine = $lines | Where-Object { $_ -match '^package ' }
    if (-not $packageLine) {
        Write-Warning "⚠️ File has no package declaration: $($file.FullName). Skipping."
        continue
    }

    # Separate sections
    $packageIndex = ($lines | Select-String '^package ').LineNumber - 1
    $imports = @()
    $otherLines = @()

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        if ($i -eq $packageIndex) {
            continue # skip, we'll re-add it
        } elseif ($line -match '^import ') {
            $imports += $line.Trim()
        } else {
            $otherLines += $line
        }
    }

    # Remove duplicate imports
    $imports = $imports | Sort-Object -Unique

    # Rebuild content
    $newContent = @()
    $newContent += $packageLine.Trim()
    $newContent += ""
    $newContent += $imports
    $newContent += ""
    $newContent += $otherLines

    # Save back
    $newContent | Set-Content -Encoding UTF8 $file.FullName

    Write-Host "✅ Fixed: $($file.FullName)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
