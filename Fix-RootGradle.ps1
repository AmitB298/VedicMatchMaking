$gradlePath = "E:\VedicMatchMaking\matchmaking-app-android\build.gradle"

@"
buildscript {
    ext.kotlin_version = "1.9.23"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.1.3"
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
"@ | Set-Content -Path $gradlePath -Encoding utf8

Write-Host "✅ build.gradle fixed successfully." -ForegroundColor Green
