<#
.SYNOPSIS
    Builds, installs, and runs an Android app on an emulator with dynamic package and activity detection.
.DESCRIPTION
    Auto-detects AVD, extracts package and main activity from project files, builds debug APK using Gradle, installs via ADB, and launches the app.
#>

# === Configuration ===
$projectRoot = "E:\VedicMatchMaking\matchmaking-app-android"
$gradlew = if ($env:OS -eq "Windows_NT") { "$projectRoot\gradlew.bat" } else { "$projectRoot/gradlew" }
$adb = "$env:ANDROID_HOME\platform-tools\adb.exe"
$emulator = "$env:ANDROID_HOME\emulator\emulator.exe"
$apkPath = "$projectRoot\app\build\outputs\apk\debug\app-debug.apk"
$manifestPath = "$projectRoot\app\src\main\AndroidManifest.xml"
$gradlePath = "$projectRoot\app\build.gradle"

# === Functions ===

function Get-PackageName {
    # Try to extract from build.gradle
    if (Test-Path $gradlePath) {
        $appId = Get-Content $gradlePath | Select-String "applicationId\s*['`"]?([^\s'`"]+)['`"]?" | ForEach-Object { $_.Matches.Groups[1].Value }
        if ($appId) {
            Write-Host "✅ Found package name in build.gradle: $appId" -ForegroundColor Green
            return $appId
        }
    }

    # Fallback to AndroidManifest.xml
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw
        if ($manifest -match 'package\s*=\s*"([^"]+)"') {
            $package = $Matches[1]
            Write-Host "✅ Found package name in AndroidManifest.xml: $package" -ForegroundColor Green
            return $package
        }
    }

    # Prompt user if not found
    Write-Warning "⚠️ Could not detect package name."
    $package = Read-Host "Please enter the package name (e.g., com.matchmaking.app)"
    if (-not $package) {
        Write-Error "❌ Package name is required."
        exit 1
    }
    return $package
}

function Get-MainActivity {
    param ([string]$PackageName)
    
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw
        # Look for activity with MAIN and LAUNCHER intent filters
        if ($manifest -match '<activity[^>]+android:name\s*=\s*"([^"]+)"[^>]*>[\s\S]*?<intent-filter>[\s\S]*?<action\s+android:name\s*=\s*"android.intent.action.MAIN"') {
            $activity = $Matches[1]
            # Convert relative name (e.g., .MainActivity) to full name
            if ($activity -match '^\.') {
                $activity = "$PackageName$activity"
            }
            Write-Host "✅ Found main activity: $activity" -ForegroundColor Green
            return $activity
        }
    }

    # Fallback to default or user input
    Write-Warning "⚠️ Could not detect main activity."
    $activity = Read-Host "Please enter the main activity (e.g., $PackageName.MainActivity) or press Enter for default ($PackageName.MainActivity)"
    if (-not $activity) {
        $activity = "$PackageName.MainActivity"
        Write-Host "Using default main activity: $activity"
    }
    return $activity
}

function Start-Emulator {
    $running = & $adb devices | Select-String "emulator-"
    if ($running) {
        Write-Host "✅ Emulator already running" -ForegroundColor Green
        return
    }

    $avds = & $emulator -list-avds
    if (-not $avds) {
        Write-Error "❌ No AVDs found. Please create one via Android Studio."
        exit 1
    }

    $avd = $avds[0]
    Write-Host "🚀 Starting emulator: $avd"
    Start-Process -FilePath $emulator -ArgumentList "-avd $avd -netdelay none -netspeed full" -WindowStyle Hidden
    Write-Host "⏳ Waiting for emulator to boot..."

    $timeoutSeconds = 300
    $startTime = Get-Date
    do {
        Start-Sleep -Seconds 5
        $booted = & $adb shell getprop sys.boot_completed 2>$null
        if ((Get-Date) - $startTime -gt [TimeSpan]::FromSeconds($timeoutSeconds)) {
            Write-Error "❌ Emulator failed to boot within $timeoutSeconds seconds."
            exit 1
        }
    } while ($booted.Trim() -ne "1")

    Write-Host "✅ Emulator is ready." -ForegroundColor Green
}

function Build-APK {
    Write-Host "🏗️ Building debug APK..." -ForegroundColor Cyan
    Set-Location $projectRoot

    & $gradlew assembleDebug | Tee-Object -Variable buildOutput
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Gradle build failed. Check output above."
        exit 1
    }

    if (-not (Test-Path $apkPath)) {
        Write-Error "❌ APK not found at $apkPath"
        exit 1
    }

    Write-Host "✅ APK built successfully." -ForegroundColor Green
}

function Install-APK {
    $devices = & $adb devices | Select-String "device$"
    if (-not $devices) {
        Write-Error "❌ No devices/emulators connected."
        exit 1
    }
    Write-Host "📱 Installing APK..." -ForegroundColor Cyan
    $result = & $adb install -r $apkPath 2>&1
    if ($LASTEXITCODE -ne 0 -or $result -match "Failure") {
        Write-Error "❌ APK installation failed: $result"
        exit 1
    }
    Write-Host "✅ APK installed successfully." -ForegroundColor Green
}

function Launch-App {
    param ([string]$Package, [string]$MainActivity)
    Write-Host "🚀 Launching MainActivity..." -ForegroundColor Cyan
    $result = & $adb shell am start -n "$Package/$MainActivity" 2>&1
    if ($LASTEXITCODE -ne 0 -or $result -match "Error") {
        Write-Error "❌ Failed to launch app: $result"
        exit 1
    }
    Write-Host "✅ App launched." -ForegroundColor Green
}

# === Main Execution ===
try {
    # Validate environment
    if (-not $env:ANDROID_HOME -or -not (Test-Path $adb) -or -not (Test-Path $emulator)) {
        Write-Error "❌ ANDROID_HOME is not set or invalid, or adb/emulator not found."
        exit 1
    }

    # Get package and main activity
    $package = Get-PackageName
    $mainActivity = Get-MainActivity -PackageName $package

    # Execute deployment steps
    Start-Emulator
    Build-APK
    Install-APK
    Launch-App -Package $package -MainActivity $mainActivity
}
catch {
    Write-Error "❌ An unexpected error occurred: $_"
    exit 1
}
finally {
    # Optional: Prompt to stop emulator
    Write-Host "🎉 Script completed. Keep emulator running? (Y/N)"
    $response = Read-Host
    if ($response -eq 'N') {
        & $adb emu kill
        Write-Host "✅ Emulator stopped." -ForegroundColor Green
    }
}