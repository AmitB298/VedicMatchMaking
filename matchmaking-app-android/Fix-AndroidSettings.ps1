<#
.SYNOPSIS
    Fixes missing or broken Android build.gradle setup for modular project
#>

$root = "E:\VedicMatchMaking\matchmaking-app-android"
$gradlew = Join-Path $root "gradlew.bat"

$modules = @("app", "user", "matchmaking", "community")

function Ensure-ModuleBuildGradle {
    foreach ($mod in $modules) {
        $modDir = Join-Path $root $mod
        $buildFile = Join-Path $modDir "build.gradle"

        if (-not (Test-Path $buildFile)) {
            Write-Host "🛠️ Creating build.gradle for module '$mod'..." -ForegroundColor Cyan

            $plugin = if ($mod -eq "app") { "com.android.application" } else { "com.android.library" }

@"
plugins {
    id '$plugin'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.vedicmatchmaking.$mod'
    compileSdk 33

    defaultConfig {
        minSdk 21
        targetSdk 33
    }
}
"@ | Set-Content -Path $buildFile -Encoding utf8
        } else {
            Write-Host "✅ build.gradle already exists in $mod"
        }
    }
}

function Ensure-RootBuildGradle {
    $rootBuild = Join-Path $root "build.gradle"
    if (-not (Test-Path $rootBuild)) {
        Write-Host "🛠️ Creating root build.gradle..." -ForegroundColor Cyan
@"
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
"@ | Set-Content -Path $rootBuild -Encoding utf8
    } else {
        Write-Host "✅ Root build.gradle already exists"
    }
}

# === MAIN ===
Ensure-ModuleBuildGradle
Ensure-RootBuildGradle

Write-Host "📦 Running assembleDebug..." -ForegroundColor Yellow
Set-Location $root
& $gradlew :app:assembleDebug
