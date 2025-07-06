<#
.SYNOPSIS
    Fixes missing modules and gradle plugin issues for multi-module Android project
#>

$root = "E:\VedicMatchMaking\matchmaking-app-android"
$gradlew = Join-Path $root "gradlew.bat"
$modules = @("app", "user", "matchmaking", "community")

function Ensure-Modules {
    foreach ($mod in $modules) {
        $modPath = Join-Path $root $mod
        if (-not (Test-Path $modPath)) {
            Write-Host "📁 Creating module folder: $mod" -ForegroundColor Cyan
            New-Item -ItemType Directory -Path $modPath | Out-Null
        }
    }
}

function Write-ModuleBuildGradle {
    param ([string]$mod)

    $modPath = Join-Path $root $mod
    $file = Join-Path $modPath "build.gradle"
    $plugin = if ($mod -eq "app") { "com.android.application" } else { "com.android.library" }

@"
plugins {
    id '$plugin'
    id 'org.jetbrains.kotlin.android'
    id 'dagger.hilt.android.plugin'
}

android {
    namespace 'com.vedicmatchmaking.$mod'
    compileSdk 33

    defaultConfig {
        minSdk 21
        targetSdk 33
    }

    buildFeatures {
        compose true
    }

    composeOptions {
        kotlinCompilerExtensionVersion '1.4.8'
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.compose.ui:ui:1.5.0"
    implementation "com.google.dagger:hilt-android:2.48"
    kapt "com.google.dagger:hilt-compiler:2.48"
}
"@ | Set-Content -Path $file -Encoding utf8
}

function Write-RootBuildGradle {
    $file = Join-Path $root "build.gradle"
@"
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
        classpath "com.google.dagger:hilt-android-gradle-plugin:2.48"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
"@ | Set-Content -Path $file -Encoding utf8
}

function Write-SettingsGradle {
    $file = Join-Path $root "settings.gradle"
    $includes = $modules -join "', '"
@"
include '$includes'
"@ | Set-Content -Path $file -Encoding utf8
}

# === MAIN ===
Ensure-Modules
$modules | ForEach-Object { Write-ModuleBuildGradle -mod $_ }
Write-RootBuildGradle
Write-SettingsGradle

Write-Host "📦 Running gradlew :app:assembleDebug..." -ForegroundColor Yellow
Set-Location $root
& $gradlew :app:assembleDebug
