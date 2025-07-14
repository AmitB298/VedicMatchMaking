param (
    [string]$AppGradlePath = ".\app\build.gradle",
    [string]$TargetVersion = "1.5.11"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Compose Compiler Version Fixer"
Write-Host "------------------------------------------------------------"

if (!(Test-Path $AppGradlePath)) {
    Write-Error "❌ ERROR: build.gradle not found at path: $AppGradlePath"
    exit 1
}

Write-Host "✅ Located build.gradle at: $AppGradlePath"

# Read all lines
$lines = Get-Content $AppGradlePath

# Replace the kotlinCompilerExtensionVersion line
$updated = $false
$lines = $lines | ForEach-Object {
    if ($_ -match 'kotlinCompilerExtensionVersion') {
        Write-Host "⚠️  Found existing line: $_"
        $updated = $true
        "        kotlinCompilerExtensionVersion '$TargetVersion'"
    } else {
        $_
    }
}

if (-not $updated) {
    Write-Host "⚠️  No existing kotlinCompilerExtensionVersion line found."
    Write-Host "✅ Appending new line to composeOptions block..."
    $newLines = @()
    $insideComposeOptions = $false
    foreach ($line in $lines) {
        $newLines += $line
        if ($line -match 'composeOptions') {
            $insideComposeOptions = $true
        } elseif ($insideComposeOptions -and $line -match '}') {
            $newLines += "        kotlinCompilerExtensionVersion '$TargetVersion'"
            $insideComposeOptions = $false
        }
    }
    $lines = $newLines
}

# Write back the updated file
$lines | Set-Content $AppGradlePath -Encoding UTF8

Write-Host "✅ Updated kotlinCompilerExtensionVersion to $TargetVersion"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "    1. Run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
Write-Host "✅ All done!"
