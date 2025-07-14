<#
.SYNOPSIS
  Fixes deprecated space-style assignments in Groovy DSL Gradle build files.
.DESCRIPTION
  Gradle 8+ deprecates 'prop value' in favor of 'prop = value'.
  This script replaces lines like:
      compileSdk 34
  with:
      compileSdk = 34
  and handles quoted values too.
.PARAMETER FilePath
  Path to your build.gradle file
.EXAMPLE
  .\Fix-GradleAssignments.ps1 -FilePath .\app\build.gradle
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Fixing Gradle Groovy DSL Deprecated Assignments"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $FilePath)) {
    Write-Error "❌ File not found: $FilePath"
    exit 1
}

$content = Get-Content -Raw -Encoding UTF8

# Perform replacements
$patterns = @(
    @{ pattern = '^\s*(compileSdk)\s+(\d+)' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(minSdk)\s+(\d+)' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(targetSdk)\s+(\d+)' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(versionCode)\s+(\d+)' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(versionName)\s+([''""].+[''""])' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(compose)\s+(true|false)' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(kotlinCompilerExtensionVersion)\s+([''""].+[''""])' ; replacement = '$1 = $2' },
    @{ pattern = '^\s*(namespace)\s+([''""].+[''""])' ; replacement = '$1 = $2' }
)

# Apply all replacements
foreach ($p in $patterns) {
    $content = $content -replace $p.pattern, $p.replacement
}

# Write back to file
Set-Content -Path $FilePath -Value $content -Encoding UTF8

Write-Host "✅ All deprecated space assignments converted to '=' assignments."
Write-Host "✅ File updated: $FilePath"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 Next step: Run ./gradlew clean assembleDebug and verify!"
Write-Host "------------------------------------------------------------"
