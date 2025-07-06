# Automate-MatrimonySetup.ps1
# Purpose: Automate setup, build, and deployment for VedicMatch matrimony app
# Usage: Run from E:\VedicMatchMaking
# Date: June 30, 2025

[CmdletBinding()]
param (
    [string]$ProjectRoot = "E:\VedicMatchMaking",
    [string]$FirebaseConfigPath = "E:\VedicMatchMaking\firebase-config.json",
    [string]$PythonCmd = "python",
    [string]$NodeCmd = "node",
    [string]$DockerCmd = "docker"
)

# Set error preference and log path
$ErrorActionPreference = 'Stop'
$logPath = Join-Path -Path $ProjectRoot -ChildPath "matrimony_setup.log"
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Function to log messages
function Write-Log {
    param ([string]$Message, [string]$Level = "Info")
    $logEntry = "[$currentTime] [$Level] $Message"
    Add-Content -Path $logPath -Value $logEntry
    $foregroundColor = if ($Level -eq "Error") { "Red" } elseif ($Level -eq "Warning") { "Yellow" } else { "White" }
    Write-Host $logEntry -ForegroundColor $foregroundColor
}

# Check if in correct directory
if ($PSScriptRoot -ne $ProjectRoot) {
    Write-Log "Please run this script from $ProjectRoot" -Level "Error"
    exit 1
}

Write-Log "Starting matrimony app automation process."

# 1. Set up environment
Write-Log "Setting up environment..."

# Install Node.js dependencies for web and backend
$webDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-web"
$backendDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-backend"
try {
    Push-Location $webDir
    Write-Log "Installing web app dependencies..."
    & npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install failed for web" }
    Pop-Location

    Push-Location $backendDir
    Write-Log "Installing backend dependencies..."
    & npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install failed for backend" }
    Pop-Location
} catch {
    Write-Log "Error setting up Node.js dependencies: $_" -Level "Error"
    exit 1
}

# Install Python dependencies for Kundli service
$kundliDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-backend\services\kundli"
try {
    Push-Location $kundliDir
    Write-Log "Installing Python dependencies..."
    & $PythonCmd -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw "pip install failed for Kundli service" }
    Pop-Location
} catch {
    Write-Log "Error setting up Python dependencies: $_" -Level "Error"
    exit 1
}

# Configure Firebase
if (Test-Path $FirebaseConfigPath) {
    Write-Log "Configuring Firebase..."
    Copy-Item -Path $FirebaseConfigPath -Destination $webDir\public -Force
    Copy-Item -Path $FirebaseConfigPath -Destination $backendDir -Force
    Write-Log "Firebase configured successfully."
} else {
    Write-Log "Firebase config file not found at $FirebaseConfigPath" -Level "Warning"
}

# 2. Build web and Android apps
Write-Log "Building applications..."

# Build web app
try {
    Push-Location $webDir
    Write-Log "Building web app..."
    & npm run build
    if ($LASTEXITCODE -ne 0) { throw "Web build failed" }
    Pop-Location
} catch {
    Write-Log "Error building web app: $_" -Level "Error"
    exit 1
}

# Build Android app
$androidDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-android"
try {
    Push-Location $androidDir
    Write-Log "Building Android app..."
    & ./gradlew assembleDebug
    if ($LASTEXITCODE -ne 0) { throw "Android build failed" }
    Pop-Location
} catch {
    Write-Log "Error building Android app: $_" -Level "Error"
    exit 1
}

# 3. Deploy Kundli microservice
$kundliServiceDir = Join-Path -Path $kundliDir -ChildPath "kundli-service"
if (-not (Test-Path $kundliServiceDir)) {
    New-Item -Path $kundliServiceDir -ItemType Directory -Force
    Copy-Item -Path (Join-Path $kundliDir "*.py") -Destination $kundliServiceDir
    Copy-Item -Path (Join-Path $kundliDir "requirements.txt") -Destination $kundliServiceDir
}

try {
    Push-Location $kundliServiceDir
    Write-Log "Building Kundli microservice Docker image..."
    & $DockerCmd build -t kundli-service:latest .
    if ($LASTEXITCODE -ne 0) { throw "Docker build failed" }
    Write-Log "Running Kundli microservice..."
    & $DockerCmd run -d -p 5001:5001 --name kundli-service kundli-service:latest
    if ($LASTEXITCODE -ne 0) { throw "Docker run failed" }
    Pop-Location
} catch {
    Write-Log "Error deploying Kundli microservice: $_" -Level "Error"
    exit 1
}

# 4. Automated testing for login
Write-Log "Running automated login tests..."

# Test web login (simulated with curl or puppeteer if installed)
$webTestUrl = "http://localhost:3000/login"
try {
    Push-Location $webDir
    Write-Log "Testing web login..."
    $testResult = & curl -X POST -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"password123"}' $webTestUrl 2>$null
    if ($testResult -match "success") {
        Write-Log "Web login test passed."
    } else {
        Write-Log "Web login test failed." -Level "Warning"
    }
    Pop-Location
} catch {
    Write-Log "Error testing web login: $_" -Level "Warning"
}

# Test Android login (requires emulator and adb)
$androidTestDevice = "emulator-5554" # Adjust based on your setup
try {
    Push-Location $androidDir
    Write-Log "Testing Android login..."
    & adb -s $androidTestDevice shell am start -n com.matchmaking.app/.MainActivity -e email "test@example.com" -e password "password123"
    Start-Sleep -Seconds 5
    $loginResult = & adb -s $androidTestDevice shell dumpsys activity | Select-String "home"
    if ($loginResult) {
        Write-Log "Android login test passed."
    } else {
        Write-Log "Android login test failed." -Level "Warning"
    }
    Pop-Location
} catch {
    Write-Log "Error testing Android login: $_" -Level "Warning"
}

# 5. Finalize and clean up
Write-Log "Matrimony app automation process completed successfully."