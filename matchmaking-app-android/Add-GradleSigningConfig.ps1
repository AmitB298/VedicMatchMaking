<#
.SYNOPSIS
Injects Android signingConfig for release build into app/build.gradle

.DESCRIPTION
- Loads keystore.properties
- Adds signingConfigs {} block
- Adds signingConfig signingConfigs.release in release buildType

.PARAMETER FilePath
Path to the build.gradle file (default: .\app\build.gradle)

.EXAMPLE
.\Add-GradleSigningConfig.ps1 -FilePath .\app\build.gradle
#>

param(
    [string]$FilePath = ".\app\build.gradle"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Android SigningConfig Injector for build.gradle"
Write-Host "------------------------------------------------------------"

# Check file exists
if (-not (Test-Path $FilePath)) {
    Write-Error "❌ File not found: $FilePath"
    exit 1
}

# Backup first
$backupPath = "$FilePath.bak"
Copy-Item $FilePath $backupPath -Force
Write-Host "✅ Backup created at $backupPath"

# Load file
$content = Get-Content -Raw -Encoding UTF8 -Path $FilePath

# Check if keystoreProperties is already loaded
if ($content -match 'keystoreProperties\s*=') {
    Write-Host "⚠️ keystoreProperties block already exists. Skipping insert."
} else {
    $keystoreLoadBlock = @"
def keystoreProperties = new Properties()
def keystoreFile = rootProject.file("keystore.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystoreFile))
}
"@

    # Insert after android { line
    $content = $content -replace '(?m)^android\s*{', "android {\n    $keystoreLoadBlock"
    Write-Host "✅ Injected keystore.properties loader"
}

# Check if signingConfigs block already exists
if ($content -match 'signingConfigs\s*{') {
    Write-Host "⚠️ signingConfigs block already exists. Skipping insert."
} else {
    $signingConfigsBlock = @"
    signingConfigs {
        release {
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }
"@

    # Insert signingConfigs before buildTypes
    $content = $content -replace '(?m)^(\s*buildTypes\s*{)', "$signingConfigsBlock`n`n$1"
    Write-Host "✅ Injected signingConfigs block"
}

# Ensure signingConfig usage in release buildType
if ($content -match 'signingConfig\s+signingConfigs.release') {
    Write-Host "⚠️ signingConfig line already exists in release buildType. Skipping insert."
} else {
    $content = $content -replace '(?m)^(\s*release\s*{)', '${1}`n        signingConfig signingConfigs.release'
    Write-Host "✅ Injected signingConfig reference in release buildType"
}

# Save updated content
Set-Content -Encoding UTF8 -Path $FilePath -Value $content
Write-Host "✅ build.gradle updated at $FilePath"
Write-Host "------------------------------------------------------------"
