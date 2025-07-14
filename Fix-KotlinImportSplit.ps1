param (
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Import Splitter & Sanitizer"
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
    $fixedLines = @()

    foreach ($line in $content) {
        # If this line contains multiple 'import' keywords jammed together
        if ($line -match "import.*import") {
            # Split on 'import' and re-add 'import' to each piece
            $parts = $line -split "import" | Where-Object { $_.Trim() -ne "" }
            foreach ($part in $parts) {
                $fixedLines += "import $($part.Trim())"
            }
        }
        else {
            $fixedLines += $line
        }
    }

    # Write fixed content back
    $fixedLines | Set-Content $file.FullName
    Write-Host "✅ Fixed imports in: $($file.Name)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
