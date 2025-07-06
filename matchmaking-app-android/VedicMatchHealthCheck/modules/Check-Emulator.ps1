param()

function Check-Emulator {
    Log-Info "🩺 Checking Android Emulator status..."

    # Try to auto-detect adb in typical locations
    $adbCandidates = @(
        "$env:ANDROID_HOME\platform-tools\adb.exe",
        "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe",
        "C:\Android\platform-tools\adb.exe"
    )

    $adbPath = $adbCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $adbPath) {
        Log-Error "❌ ADB not found in standard locations. Please install Android SDK and ensure platform-tools are available."
        return
    }

    Log-Info "✅ Using ADB at: $adbPath"

    try {
        $devices = & $adbPath devices
        if ($devices -match "emulator-") {
            Log-Info "✅ Emulator detected and running."
        } else {
            Log-Warning "⚠️  No emulator detected. Please start one for full testing."
        }
    }
    catch {
        Log-Error "❌ Error while running adb: $($_.Exception.Message)"
    }
}
