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

$files = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt

if (-Not $files) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $modified = $false

    # Find package line
    $packageIndex = ($content | Select-String -Pattern '^\s*package\s').LineNumber
    if ($packageIndex -eq $null) {
        Write-Warning "⚠️ No package declaration in $($file.Name). Skipping."
        continue
    }

    # Check if @file:OptIn is already present
    $hasOptIn = $content | Select-String -Pattern '@file:OptIn'

    if (-Not $hasOptIn) {
        Write-Host "🔎 Processing $($file.FullName)"
        $optInLine = '@file:OptIn(ExperimentalMaterial3Api::class)'
        # Insert @file:OptIn after package
        $newContent = @()
        for ($i = 0; $i -lt $content.Count; $i++) {
            $newContent += $content[$i]
            if ($i -eq ($packageIndex - 1)) {
                $newContent += $optInLine
            }
        }
        $newContent | Set-Content $file.FullName
        Write-Host "✅ Added @file:OptIn to $($file.Name)"
        $modified = $true
    }

    if ($modified) {
        Write-Host "✅ Fixed: $($file.Name)"
    } else {
        Write-Host "✅ No changes needed: $($file.Name)"
    }
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
