<#
.SYNOPSIS
  Safely fixes and injects Android signingConfigs in app/build.gradle.
.DESCRIPTION
  - Removes duplicate signingConfigs blocks.
  - Ensures clean single signingConfigs block.
  - Injects if missing.
  - Cleans release buildType of duplicate signingConfig lines.
#>

param (
  [Parameter(Mandatory = $true)]
  [string]$FilePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Advanced Gradle SigningConfigs Fixer"
Write-Host "------------------------------------------------------------"

# 1️⃣ Backup
$backupPath = "$FilePath.bak"
Copy-Item $FilePath $backupPath -Force
Write-Host "✅ Backup created at $backupPath"

# 2️⃣ Load content
$content = Get-Content $FilePath -Raw

# 3️⃣ Remove ALL duplicate signingConfigs blocks
$patternSigningConfigs = '(?ms)signingConfigs\s*\{.*?\}'
if ($content -match $patternSigningConfigs) {
    $content = [regex]::Replace($content, $patternSigningConfigs, '')
    Write-Host "✅ Removed existing signingConfigs blocks"
}

# 4️⃣ Remove duplicate signingConfig lines in release block
$patternReleaseConfig = '(?m)^\s*signingConfig\s+signingConfigs\.release\s*$'
if ($content -match $patternReleaseConfig) {
    $content = [regex]::Replace($content, $patternReleaseConfig, '')
    Write-Host "✅ Removed duplicate signingConfig lines in release buildType"
}

# 5️⃣ Prepare clean signingConfigs block
$signingBlock = @"
signingConfigs {
    release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
    }
}
"@

# 6️⃣ Insert signingConfigs after 'android {'
$replacement = "android {" + "`r`n" + $signingBlock
$content = $content -replace '(?m)^android\s*\{', $replacement

# 7️⃣ Add signingConfig reference in release buildType
$patternBuildTypes = '(?ms)buildTypes\s*\{.*?release\s*\{'
if ($content -match $patternBuildTypes) {
    $content = [regex]::Replace(
        $content,
        '(?ms)(release\s*\{)',
        "`$1`r`n            signingConfig signingConfigs.release"
    )
    Write-Host "✅ Ensured signingConfig in release buildType"
}

# 8️⃣ Save updated content
Set-Content -Path $FilePath -Value $content -Encoding UTF8
Write-Host "✅ build.gradle cleaned and updated at $FilePath"

Write-Host "------------------------------------------------------------"
