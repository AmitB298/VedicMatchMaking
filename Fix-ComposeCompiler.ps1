# Fix-ComposeCompiler.ps1
$ErrorActionPreference = "Stop"
$propsPath = "gradle.properties"
$appGradlePath = "app\build.gradle"
$requiredKotlinVersion = "1.9.23"
$requiredComposeVersion = "1.5.11"

# Step 1: Ensure kotlinCompilerExtensionVersion in gradle.properties
if (-not (Get-Content $propsPath | Select-String "kotlinCompilerExtensionVersion")) {
    Add-Content $propsPath "`nkotlinCompilerExtensionVersion=$requiredComposeVersion"
    Write-Host "🧩 Added kotlinCompilerExtensionVersion=$requiredComposeVersion to gradle.properties" -ForegroundColor Green
} else {
    Write-Host "✅ kotlinCompilerExtensionVersion already present in gradle.properties" -ForegroundColor Yellow
}

# Step 2: Ensure composeOptions in app/build.gradle
$gradleText = Get-Content $appGradlePath -Raw
if ($gradleText -notmatch "composeOptions\s*{") {
    # Inject into android block
    $gradleText = $gradleText -replace "(android\s*{)", "`$1`n    buildFeatures {\n        compose true\n    }\n    composeOptions {\n        kotlinCompilerExtensionVersion '$requiredComposeVersion'\n    }"
    Set-Content -Path $appGradlePath -Value $gradleText -Encoding utf8
    Write-Host "🛠️ Injected composeOptions into app/build.gradle" -ForegroundColor Green
} else {
    Write-Host "✅ composeOptions already configured in app/build.gradle" -ForegroundColor Yellow
}

# Step 3: Check Kotlin version in build.gradle
if ($gradleText -match "kotlin\s*version\s*['\"](\d+\.\d+\.\d+)['\"]") {
    $versionUsed = $Matches[1]
    if ($versionUsed -ne $requiredKotlinVersion) {
        Write-Warning "⚠️ Kotlin version in build.gradle is $versionUsed but expected $requiredKotlinVersion."
        Write-Warning "👉 Update your build.gradle or buildSrc to use Kotlin $requiredKotlinVersion."
    } else {
        Write-Host "✅ Kotlin version $requiredKotlinVersion is correctly used." -ForegroundColor Green
    }
} else {
    Write-Warning "⚠️ Could not detect Kotlin version from build.gradle."
}

# Step 4: Run build
Write-Host "`n🚀 Running Gradle build..." -ForegroundColor Cyan
.\gradlew.bat clean :app:assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Build succeeded!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
