<#
.SYNOPSIS
    Builds and installs debug APK from correct module in a modular Android project.
.DESCRIPTION
    Detects modules containing assembleDebug, builds APK, installs on emulator, launches main activity.
#>

$root = "E:\VedicMatchMaking\matchmaking-app-android"
$gradlew = Join-Path $root "gradlew.bat"
$adb = "$env:ANDROID_HOME\platform-tools\adb.exe"

function Ensure-Emulator {
    $running = & $adb devices | Select-String "emulator-"
    if ($running) {
        Write-Host "✅ Emulator already running" -ForegroundColor Green
        return
    }

    Write-Host "❌ No emulator running. Please start one." -ForegroundColor Red
    exit 1
}

function Find-DebugModule {
    Write-Host "🔍 Finding modules with assembleDebug..." -ForegroundColor Cyan
    $output = & $gradlew tasks --all | Out-String
    $matches = Select-String -InputObject $output -Pattern '(^:.*):assembleDebug' -AllMatches

    if ($matches.Count -eq 0) {
        Write-Error "❌ assembleDebug not found in any module"
        exit 1
    }

    # Return first matching module (modify if needed to prioritize `:app` or `:user`)
    return $matches[0].Matches[0].Groups[1].Value
}

function Build-APK {
    param([string]$module)

    Write-Host "🏗️ Building APK in $module..." -ForegroundColor Cyan
    $task = "$module:assembleDebug"
    $result = & $gradlew $task | Tee-Object -Variable buildOutput

    # Normalize module folder name (e.g., ':user' -> 'user')
    $folder = $module.TrimStart(':').Replace(':', '\')
    $apkPath = Join-Path -Path "$root\$folder" -ChildPath "build\outputs\apk\debug\app-debug.apk"

    if (-not (Test-Path $apkPath)) {
        Write-Error "❌ APK build failed or file not found at $apkPath"
        exit 1
    }

    return $apkPath
}

function Install-APK {
    param([string]$apkPath)

    Write-Host "📱 Installing APK..." -ForegroundColor Cyan
    & $adb install -r $apkPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ App installed successfully" -ForegroundColor Green
    } else {
        Write-Error "❌ Failed to install APK"
        exit 1
    }
}

function Launch-App {
    $packages = & $adb shell pm list packages | ForEach-Object { $_ -replace 'package:', '' }

    # Try to find your app (update with known ID if needed)
    $target = $packages | Where-Object { $_ -like "*match*" } | Select-Object -First 1

    if (-not $target) {
        Write-Warning "⚠️ Could not detect package. Please open app manually."
        return
    }

    Write-Host "🚀 Launching $target" -ForegroundColor Cyan
    & $adb shell monkey -p $target -c android.intent.category.LAUNCHER 1
}

# MAIN EXECUTION
Set-Location $root
Ensure-Emulator
$module = Find-DebugModule
$apk = Build-APK -module $module
Install-APK -apkPath $apk
Launch-App
