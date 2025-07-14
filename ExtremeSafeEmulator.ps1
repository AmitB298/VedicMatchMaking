# ExtremeSafeEmulator.ps1
Write-Output "------------------------------------------------------------"
Write-Output "✅ Android Emulator EXTREME SAFE MODE Cleanup & Config"
Write-Output "------------------------------------------------------------"

# 1️⃣ Kill emulator and qemu processes
Write-Output "✅ Killing existing emulator processes..."
taskkill /F /IM emulator.exe -ErrorAction SilentlyContinue
taskkill /F /IM qemu-system-x86_64.exe -ErrorAction SilentlyContinue

# 2️⃣ Clean TEMP running state
Write-Output "✅ Cleaning TEMP running state..."
Remove-Item "$env:TEMP\avd\running" -Recurse -Force -ErrorAction SilentlyContinue

# 3️⃣ Kill ADB server
Write-Output "✅ Killing ADB server..."
adb kill-server

# 4️⃣ Remove broken snapshots (these cause boot freezes)
Write-Output "✅ Removing corrupted snapshots..."
$avdHome = "$HOME\.android\avd\Pixel_5_API_33.avd\snapshots"
if (Test-Path $avdHome) {
    Remove-Item $avdHome -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "✅ Snapshots removed at $avdHome"
}

# 5️⃣ Patch config.ini for EXTREME SAFE MODE
Write-Output "✅ Patching config.ini for software rendering and low RAM..."
$configPath = "$HOME\.android\avd\Pixel_5_API_33.avd\config.ini"
if (Test-Path $configPath) {
    (Get-Content $configPath) |
        ForEach-Object {
            if ($_ -match "^hw\.gpu\.mode=") { "hw.gpu.mode=off" }
            elseif ($_ -match "^hw\.gpu\.enabled=") { "hw.gpu.enabled=no" }
            elseif ($_ -match "^hw\.ramSize=") { "hw.ramSize=512" }
            else { $_ }
        } | Set-Content $configPath -Encoding UTF8
    Write-Output "✅ Config patched at $configPath"
}

# 6️⃣ Restart ADB
Write-Output "✅ Restarting ADB server..."
adb start-server
adb devices

Write-Output "------------------------------------------------------------"
Write-Output "✅ CLEANUP COMPLETE."
Write-Output "------------------------------------------------------------"
Write-Output ""
Write-Output "👉 Recommended LAUNCH COMMAND:"
Write-Output "   .\emulator.exe -avd Pixel_5_API_33 -no-snapshot -no-boot-anim -gpu off -memory 512"
Write-Output ""
Write-Output "✅ This is the EXTREME SAFE MODE setup for low-end machines!"
