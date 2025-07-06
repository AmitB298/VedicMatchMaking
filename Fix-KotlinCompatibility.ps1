# Fix-KotlinCompatibility.ps1

$ErrorActionPreference = "Stop"
$basePath = "E:\VedicMatchMaking\matchmaking-app-android"
$propsPath = Join-Path $basePath "gradle.properties"
$requiredKotlinVersion = "1.9.0"
$requiredComposeVersion = "1.5.11"

Write-Host "🔍 Scanning project for Kotlin/Compose version issues..." -ForegroundColor Cyan

# Step 1: Patch all build.gradle files with correct Kotlin version
$gradleFiles = Get-ChildItem -Path $basePath -Recurse -Include "build.gradle" -File

foreach ($file in $gradleFiles) {
    $content = Get-Content $file.FullName -Raw
    $original = $content

    # Replace Kotlin version inside plugins or ext.kotlin_version
    $content = $content -replace "(kotlin(?:-android|-jvm)?[\"']?\s*:\s*[\"'])1\.9\.23([\"'])", "`$11.9.0`$2"
    $content = $content -replace "(ext\.kotlin_version\s*=\s*[\"'])1\.9\.23([\"'])", "`$11.9.0`$2"

    if ($content -ne $original) {
        Set-Content $file.FullName $content -Encoding utf8
        Write-Host "🛠️ Patched Kotlin version in $($file.FullName)" -ForegroundColor Green
    }
}

# Step 2: Ensure gradle.properties has correct Compose compiler extension version
if (-not (Test-Path $propsPath)) {
    New-Item -ItemType File -Path $propsPath -Force | Out-Null
    Write-Host "🆕 Created gradle.properties file." -ForegroundColor Cyan
}
$props = Get-Content $propsPath
if (-not ($props -match "kotlinCompilerExtensionVersion")) {
    Add-Content $propsPath "`nkotlinCompilerExtensionVersion=$requiredComposeVersion"
    Write-Host "✅ Set kotlinCompilerExtensionVersion=$requiredComposeVersion in gradle.properties" -ForegroundColor Green
} else {
    Write-Host "✅ kotlinCompilerExtensionVersion already set." -ForegroundColor Yellow
}

# Step 3: Run Gradle Build
Write-Host "`n🚀 Running Gradle build..." -ForegroundColor Cyan
Push-Location $basePath
.\gradlew.bat clean :app:assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Build succeeded!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
Pop-Location
