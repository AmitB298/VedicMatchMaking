param(
    [string]$RootBuildFile = "E:\VedicCouple\matchmaking-app-android\build.gradle"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Checking ROOT build.gradle at: $RootBuildFile"
Write-Host "------------------------------------------------------------"

if (!(Test-Path $RootBuildFile)) {
    Write-Warning "⚠️  File not found. Creating new build.gradle..."
    @"
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.3'
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.dagger:hilt-android-gradle-plugin:2.52'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
"@ | Out-File $RootBuildFile -Encoding utf8
    Write-Host "✅ New ROOT build.gradle created."
} else {
    $content = Get-Content $RootBuildFile
    if ($content -notmatch 'com.google.gms:google-services') {
        Write-Host "⚠️  Missing google-services classpath. Patching..."
        $patched = $content -replace 'dependencies\s*{', "dependencies {\n        classpath 'com.google.gms:google-services:4.4.0'"
        $patched | Out-File $RootBuildFile -Encoding utf8
        Write-Host "✅ ROOT build.gradle patched with google-services."
    } else {
        Write-Host "✅ ROOT build.gradle already includes google-services."
    }
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
