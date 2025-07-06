param(
    [string]$AndroidProjectPath = ".\matchmaking-app-android",
    [string]$EmulatorName = ""
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking Android Auth Test Automation Tool" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------"

# 1️⃣ Check for screen files
$loginPath = Join-Path $AndroidProjectPath "app\src\main\java\com\matchmaking\app\ui\screens\LoginScreen.kt"
$registerPath = Join-Path $AndroidProjectPath "app\src\main\java\com\matchmaking\app\ui\screens\RegisterScreen.kt"

Write-Host ""
Write-Host "📜 Checking for Login and Register Screens..." -ForegroundColor Yellow

if (!(Test-Path $loginPath)) {
    Write-Host "❌ ERROR: Missing LoginScreen.kt at $loginPath" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Found: LoginScreen.kt" -ForegroundColor Green
}

if (!(Test-Path $registerPath)) {
    Write-Host "❌ ERROR: Missing RegisterScreen.kt at $registerPath" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Found: RegisterScreen.kt" -ForegroundColor Green
}

# 2️⃣ Ask about emulator
Write-Host ""
Write-Host "📜 Available Emulators:" -ForegroundColor Yellow
& "$Env:ANDROID_HOME\emulator\emulator.exe" -list-avds

if ($EmulatorName -eq "") {
    $EmulatorName = Read-Host "👉 Enter the Emulator Name to launch (or press Enter to skip)"
}

if ($EmulatorName -ne "") {
    Write-Host ""
    Write-Host "🚀 Starting Emulator: $EmulatorName" -ForegroundColor Cyan
    Start-Process "$Env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList @("-avd", $EmulatorName) -WindowStyle Normal

    # Wait for boot
    Write-Host ""
    Write-Host "⏳ Waiting for emulator to boot completely..." -ForegroundColor Yellow
    & "$Env:ANDROID_HOME\platform-tools\adb.exe" wait-for-device

    do {
        $bootstatus = & "$Env:ANDROID_HOME\platform-tools\adb.exe" shell getprop sys.boot_completed
        Write-Host "🔎 Boot Status: $bootstatus"
        Start-Sleep -Seconds 5
    } while ($bootstatus -ne "1")

    Write-Host ""
    Write-Host "✅ Emulator is fully booted!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ℹ️ Skipping emulator launch as requested." -ForegroundColor Gray
}

# 3️⃣ Gradle Clean
Write-Host ""
Write-Host "⚙️ Running Gradle Clean..." -ForegroundColor Cyan
Set-Location $AndroidProjectPath
if (Test-Path ".\gradlew") {
    .\gradlew clean
    Write-Host "✅ Gradle Clean complete." -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: gradlew not found in $AndroidProjectPath" -ForegroundColor Red
    exit 1
}

# 4️⃣ Gradle Install Debug
Write-Host ""
Write-Host "⚙️ Building and installing Debug APK on Emulator/Device..." -ForegroundColor Cyan
.\gradlew installDebug
Write-Host "✅ App installed successfully." -ForegroundColor Green

# 5️⃣ User instructions
Write-Host ""
Write-Host "📢 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------"
Write-Host "✅ Your Emulator (or connected device) is ready."
Write-Host "✅ The App is installed."
Write-Host ""
Write-Host "👉 Please open your app on the Emulator or Device."
Write-Host "👉 Navigate to the Login or Register screen."
Write-Host "👉 Enter email, password, displayName."
Write-Host "👉 Tap Register or Login to test your backend."
Write-Host ""
Write-Host "✨ Happy Testing!"
Write-Host "-----------------------------------------------------------"
