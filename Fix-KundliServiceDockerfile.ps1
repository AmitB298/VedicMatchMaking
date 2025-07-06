<#
.SYNOPSIS
    Fixes the Dockerfile for the kundli-service by correcting file paths and ensuring a successful Docker build.

.DESCRIPTION
    Updates the Dockerfile in the kundli-service directory to copy Kundli-related files (e.g., kundli_calculator.py, kundli_api.py, swiss_ephe) from the parent directory using absolute paths. Backs up the existing Dockerfile, validates file existence, checks for .dockerignore issues, and optionally triggers a Docker build with the correct context.

.PARAMETER ServicePath
    Path to the kundli-service directory containing the Dockerfile. Default: E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service

.PARAMETER Build
    Switch to trigger a Docker build after updating the Dockerfile.

.EXAMPLE
    .\Fix-KundliServiceDockerfile.ps1 -ServicePath "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service" -Build
    Updates the Dockerfile and builds the kundli-service image.

.EXAMPLE
    .\Fix-KundliServiceDockerfile.ps1
    Updates the Dockerfile without building.
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$ServicePath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service",
    
    [switch]$Build
)

# Function to log messages
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
}

# Validate ServicePath
Write-Log "🛠️ Starting Kundli Service Dockerfile fixer..."
if (-not (Test-Path $ServicePath)) {
    Write-Log "❌ Error: Service path '$ServicePath' does not exist."
    exit 1
}

# Define paths
$dockerfilePath = Join-Path $ServicePath "Dockerfile"
$backupPath = Join-Path $ServicePath "Dockerfile.bak"
$parentPath = Split-Path $ServicePath -Parent
$requirementsPath = Join-Path $parentPath "requirements.txt"
$swissEphePath = Join-Path $parentPath "swiss_ephe"
$kundliCalculatorPath = Join-Path $parentPath "kundli_calculator.py"
$kundliApiPath = Join-Path $parentPath "kundli_api.py"
$dockerIgnorePath = Join-Path $ServicePath ".dockerignore"

# Validate required files
$requiredFiles = @($requirementsPath, $swissEphePath, $kundliCalculatorPath, $kundliApiPath)
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Log "❌ Error: Required file or directory '$file' is missing."
        exit 1
    }
}

# Check for .dockerignore that might exclude parent files
if (Test-Path $dockerIgnorePath) {
    $dockerIgnoreContent = Get-Content $dockerIgnorePath
    if ($dockerIgnoreContent -match '\.\./') {
        Write-Log "⚠️ Warning: .dockerignore contains '../', which may prevent copying parent directory files."
        Write-Log "ℹ️ Consider removing '../' from .dockerignore or modifying it."
    }
}

# Backup existing Dockerfile
if (Test-Path $dockerfilePath) {
    Write-Log "🔎 Found existing Dockerfile. Backing it up..."
    Copy-Item -Path $dockerfilePath -Destination $backupPath -Force
    Write-Log "✅ Backup created at: $backupPath"
} else {
    Write-Log "ℹ️ No existing Dockerfile found. Creating a new one."
}

# Define new Dockerfile content with absolute paths relative to parent context
$dockerfileContent = @"
# Use Python 3.11 slim base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy Swiss Ephemeris files
COPY services/kundli/swiss_ephe ./swiss_ephe

# Copy requirements file
COPY services/kundli/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Kundli service code
COPY services/kundli/kundli-service .

# Copy Kundli calculation and API files
COPY services/kundli/kundli_calculator.py .
COPY services/kundli/kundli_api.py .

# Expose port for Flask
EXPOSE 5000

# Run the Flask app
CMD ["python", "kundli_api.py"]
"@

# Write new Dockerfile
Write-Log "✍️ Writing new Dockerfile..."
Set-Content -Path $dockerfilePath -Value $dockerfileContent -Force
Write-Log "✅ New Dockerfile written to: $dockerfilePath"

# Optionally build the Docker image with parent context
if ($Build) {
    Write-Log "🚀 Building Docker image for kundli-service..."
    try {
        # Use parent directory as build context to access kundli files
        Set-Location (Split-Path $parentPath -Parent) # E:\VedicMatchMaking\matchmaking-app-backend
        $buildOutput = docker build -t kundli-service -f services/kundli/kundli-service/Dockerfile . 2>&1
        Write-Log "✅ Docker build completed successfully."
        Write-Log $buildOutput
    } catch {
        Write-Log "❌ Error during Docker build: $_"
        Write-Log $buildOutput
        exit 1
    }
}

Write-Log "🎯 Done! Kundli-service Dockerfile is updated and ready."