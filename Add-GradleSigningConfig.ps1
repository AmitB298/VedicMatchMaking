<#
.SYNOPSIS
Automates adding signingConfigs to Android app/build.gradle.
#>

param(
    [string]$BuildGradlePath = ".\app\build.gradle",
    [string]$KeystorePropertiesPath = ".\keystore.properties"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Android SigningConfig Injector for build.gradle"
Write-Host "------------------------------------------------------------"

if (!(Test-Path $BuildGradlePath)) {
    Write-Error "❌ ERROR: build.gradle not found at $BuildGradlePath"
    exit 1
}

if (!(Test-Path $KeystorePropertiesPath)) {
    Write-Error "❌ ERROR: keystore.properties not found at $KeystorePropertiesPath"
    exit 1
}

# Backup original
$BackupPath = "$BuildGradlePath.bak"
Copy-Item $BuildGradlePath $BackupPath -Force
Write-Host "✅ Backup created at $BackupPath"

# Load build.gradle content
$content = Get-Content $BuildGradlePath -Raw

# Check if already has signingConfigs
if ($content -match "signingConfigs\s*\{") {
    Write-Warning "⚠️ build.gradle already contains a signingConfigs block. No changes made."
    exit 0
}

# Prepare signingConfigs Groovy block
$signingBlock = @'
signingConfigs {
    release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
    }
}
'@

# Prepare Groovy properties loading
$propertiesLoad = @'
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
'@

# Inject properties loader at top
if ($content -notmatch "keystorePropertiesFile") {
    $content = $propertiesLoad + "`n`n" + $content
    Write-Host "✅ Injected keystore.properties loader"
}

# Inject signingConfigs inside android { }
if ($content -match "android\s*{") {
    $content = $content -replace "(android\s*{)", "`$1`n    $signingBlock"
    Write-Host "✅ Injected signingConfigs block"
}

# Fix release buildType
$content = $content -replace '(buildTypes\s*{\s*release\s*{)', '$1' + "`n            signingConfig signingConfigs.release"

# Write back
Set-Content -Path $BuildGradlePath -Value $content -Encoding UTF8
Write-Host "✅ build.gradle updated at $BuildGradlePath"
Write-Host "------------------------------------------------------------"
