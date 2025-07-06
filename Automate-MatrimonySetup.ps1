# Automate-MatrimonySetup.ps1
# Purpose: Automate setup, build, and deployment for VedicMatch matrimony app
# Usage: Run from E:\VedicMatchMaking
# Date: July 02, 2025

[CmdletBinding()]
param (
    [string]$ProjectRoot = "E:\VedicMatchMaking",
    [string]$FirebaseConfigPath = "E:\VedicMatchMaking\firebase-config.json",
    [string]$PythonCmd = "python",
    [string]$NodeCmd = "node",
    [string]$DockerCmd = "docker",
    [string]$MongodPath = "mongod" # Path to mongod executable, adjust if needed
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

# 1. Start MongoDB server
Write-Log "Preparing and starting local MongoDB server..."
$dataPath = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-backend\data"
try {
    if (-not (Test-Path $dataPath)) {
        Write-Log "Creating data directory at $dataPath..."
        New-Item -Path $dataPath -ItemType Directory -Force | Out-Null
        if (-not (Test-Path $dataPath)) {
            throw "Failed to create data directory $dataPath. Check permissions."
        }
    }
    Write-Log "Starting MongoDB server with data path $dataPath..."
    $mongoProcess = Start-Process -FilePath $MongodPath -ArgumentList "--dbpath $dataPath" -NoNewWindow -PassThru -RedirectStandardError "mongod_error.log"
    Start-Sleep -Seconds 10 # Increased delay to ensure server starts
    $mongoRunning = Get-Process mongod -ErrorAction SilentlyContinue
    if ($mongoRunning) {
        Write-Log "MongoDB server started successfully."
    } else {
        $errorMsg = Get-Content -Path "mongod_error.log" -Raw
        throw "MongoDB server failed to start. Error: $errorMsg"
    }
} catch {
    Write-Log "Error starting MongoDB server: $($_.Exception.Message)" -Level "Error"
    exit 1
} finally {
    if (Test-Path "mongod_error.log") {
        Start-Sleep -Seconds 5
        try {
            Remove-Item "mongod_error.log" -Force
            Write-Log "Cleaned up mongod_error.log."
        } catch {
            Write-Log "Failed to clean up mongod_error.log: $($_.Exception.Message)" -Level "Warning"
        }
    }
}

# 2. Start Docker Desktop (if not running)
Write-Log "Checking and starting Docker Desktop..."
try {
    $dockerRunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if (-not $dockerRunning) {
        Write-Log "Docker Desktop not running. Attempting to start..."
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -NoNewWindow -PassThru
        Start-Sleep -Seconds 20 # Allow time for Docker to start
        $dockerTest = & $DockerCmd ps 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker failed to start. Please ensure Docker Desktop is installed and configured."
        }
        Write-Log "Docker Desktop started successfully."
    } else {
        Write-Log "Docker Desktop is already running."
    }
} catch {
    Write-Log "Error starting Docker Desktop: $($_.Exception.Message)" -Level "Error"
    exit 1
}

# 3. Set up environment
Write-Log "Setting up environment..."

# Install Node.js dependencies for web and backend
$webDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-web"
$backendDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-backend"
try {
    Push-Location $webDir
    Write-Log "Installing web app dependencies..."
    & npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install failed for web" }
    $progressBarPath = Join-Path -Path $webDir -ChildPath "src\components\ProgressBar.tsx"
    if (-not (Test-Path $progressBarPath)) {
        $progressBarContent = @"
import React from 'react';

interface ProgressBarProps {
  value: number; // 0 to 100
  max?: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ value, max = 100 }) => {
  const width = Math.min(Math.max(value, 0), max) / max * 100;

  return (
    <div className='w-full bg-gray-200 rounded-full h-4'>
      <div
        className='h-full bg-green-500 rounded-full transition-all'
        style={{ width: `${width}%` }}
      />
    </div>
  );
};

export default ProgressBar;
"@
        $progressBarContent | Out-File -FilePath $progressBarPath -Encoding UTF8
        Write-Log "Created ProgressBar.tsx."
    }
    Pop-Location

    Push-Location $backendDir
    Write-Log "Installing backend dependencies..."
    & npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install failed for backend" }
    Pop-Location
} catch {
    Write-Log "Error setting up Node.js dependencies: $($_.Exception.Message)" -Level "Error"
    exit 1
}

# Install Python dependencies for Kundli service
$kundliDir = Join-Path -Path $ProjectRoot -ChildPath "matchmaking-app-backend\services\kundli"
try {
    Push-Location $kundliDir
    Write-Log "Installing Python dependencies..."
    & $PythonCmd -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        $errorDetail = $_.Exception.Message
        Write-Log "Failed to install Python dependencies. Error: $errorDetail" -Level "Error"
        exit 1
    }
    Pop-Location
} catch {
    $errorDetail = $_.Exception.Message
    Write-Log "Error setting up Python dependencies: $errorDetail" -Level "Error"
    exit 1
}

# Configure Firebase (optional)
if (Test-Path $FirebaseConfigPath) {
    Write-Log "Configuring Firebase..."
    Copy-Item -Path $FirebaseConfigPath -Destination $webDir\public -Force
    Copy-Item -Path $FirebaseConfigPath -Destination $backendDir -Force
    Write-Log "Firebase configured successfully."
} else {
    Write-Log "Firebase config file not found at $FirebaseConfigPath. Skipping configuration." -Level "Warning"
}

# 2. Build web and Android apps
Write-Log "Building applications..."

# Build web app with retry
$maxAttempts = 2
$attempt = 1
$webBuildSuccess = $false
while ($attempt -le $maxAttempts -and -not $webBuildSuccess) {
    try {
        Push-Location $webDir
        Write-Log "Building web app (Attempt $attempt)..."
        & npm run build
        if ($LASTEXITCODE -ne 0) { throw "Web build failed" }
        $webBuildSuccess = $true
        Pop-Location
    } catch {
        Write-Log "Web build failed: $($_.Exception.Message)" -Level "Warning"
        if ($attempt -eq $maxAttempts) {
            Write-Log "Max retries reached. Web build failed." -Level "Error"
            exit 1
        }
        $attempt++
        Start-Sleep -Seconds 5
    }
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
    Write-Log "Error building Android app: $($_.Exception.Message)" -Level "Error"
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
    if ($LASTEXITCODE -ne 0) {
        throw "Docker build failed. Please ensure Docker Desktop is running and configured."
    }
    Write-Log "Running Kundli microservice..."
    & $DockerCmd run -d -p 5001:5001 --name kundli-service kundli-service:latest
    if ($LASTEXITCODE -ne 0) {
        throw "Docker run failed. Please check Docker logs."
    }
    Pop-Location
} catch {
    Write-Log "Error deploying Kundli microservice: $($_.Exception.Message)" -Level "Error"
    exit 1
}

# 4. Automated testing for login
Write-Log "Running automated login tests..."

# Test web login (simulated with curl)
$webTestUrl = "http://localhost:3000/login"
try {
    Push-Location $webDir
    Write-Log "Testing web login with MongoDB..."
    $testResult = & curl -X POST -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"password123"}' $webTestUrl 2>$null
    if ($testResult -match "success" -or $testResult -match "home") {
        Write-Log "Web MongoDB login test passed."
    } else {
        Write-Log "Web MongoDB login test failed. Result: $testResult" -Level "Warning"
    }
    Pop-Location
} catch {
    Write-Log "Error testing web MongoDB login: $($_.Exception.Message)" -Level "Warning"
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
    Write-Log "Error testing Android login: $($_.Exception.Message)" -Level "Warning"
}

# 5. Stop MongoDB server
Write-Log "Stopping MongoDB server..."
try {
    $mongoProcess = Get-Process mongod -ErrorAction SilentlyContinue
    if ($mongoProcess) {
        Stop-Process -Name "mongod" -Force
        Start-Sleep -Seconds 3 # Wait for process to terminate
        Write-Log "MongoDB server stopped successfully."
    } else {
        Write-Log "MongoDB server not running."
    }
} catch {
    Write-Log "Error stopping MongoDB server: $($_.Exception.Message)" -Level "Warning"
}

# 6. Stop Docker containers (optional cleanup)
Write-Log "Stopping Docker containers..."
try {
    & $DockerCmd stop kundli-service 2>$null
    & $DockerCmd rm kundli-service 2>$null
    Write-Log "Docker containers stopped and removed."
} catch {
    Write-Log "Error stopping Docker containers: $($_.Exception.Message)" -Level "Warning"
}

# 7. Finalize and clean up
Write-Log "Matrimony app automation process completed."