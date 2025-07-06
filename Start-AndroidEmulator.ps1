<#
.SYNOPSIS
    Starts a selected Android Emulator and waits until it's booted.
#>

param (
    [string]$AVD = "Pixel_6_Pro"
)

$emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
$adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"

if (-not (Test-Path $emulatorPath)) {
    Write-Error "❌ Emulator not found at $emulatorPath"
    exit 1
}

if (-not (Test-Path $adbPath)) {
    Write-Error "❌ adb not found at $adbPath"
    exit 1
}

# Step 1: Check if emulator is already running
$running = & $adbPath devices | Select-String "emulator-"
if ($running) {
    Write-Host "✅ Emulator already running." -ForegroundColor Green
    exit 0
}

# Step 2: Launch emulator
Write-Host "🚀 Starting emulator: $AVD" -ForegroundColor Cyan
Start-Process -FilePath $emulatorPath -ArgumentList "-avd `"$AVD`" -no-snapshot-save -netdelay none -netspeed full" -WindowStyle Hidden

# Step 3: Wait until emulator appears in adb
Write-Host "⏳ Waiting for emulator to show up in adb..."
$deviceConnected = $false
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 2
    $devices = & $adbPath devices
    if ($devices -match "emulator-") {
        $deviceConnected = $true
        break
    }
}
if (-not $deviceConnected) {
    Write-Error "❌ Emulator failed to appear in adb after 2 minutes."
    exit 1
}

# Step 4: Wait until boot complete
Write-Host "⏳ Waiting for system boot..."
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 5
    $bootComplete = & $adbPath shell getprop sys.boot_completed 2>$null
    if ($bootComplete -and $bootComplete.Trim() -eq "1") {
        Write-Host "✅ Emulator fully booted and ready." -ForegroundColor Green
        exit 0
    }
}

Write-Error "❌ Emulator launched but did not finish booting in time."
exit 1
