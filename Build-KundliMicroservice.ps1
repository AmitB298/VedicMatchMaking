# Set strict error handling
$ErrorActionPreference = "Stop"

# Paths
$KundliPath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service"
$DockerfilePath = Join-Path $KundliPath "Dockerfile"
$ImageName = "kundli-service"

Write-Host "[Info] Checking Docker status..." -ForegroundColor Cyan
# Check if Docker is running
try {
    docker info > $null
    Write-Host "[OK] Docker is running." -ForegroundColor Green
} catch {
    Write-Host "[Error] Docker is not running. Start Docker Desktop and retry." -ForegroundColor Red
    exit 1
}

# Go to kundli-service directory
Set-Location $KundliPath

Write-Host "[Info] Checking for Dockerfile in: $KundliPath" -ForegroundColor Cyan
if (-Not (Test-Path $DockerfilePath)) {
    Write-Host "[Warning] Dockerfile not found. Creating a default one..." -ForegroundColor Yellow

    @"
# Default Dockerfile for Kundli Flask microservice
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
CMD ["python", "main.py"]
"@ | Set-Content -Path $DockerfilePath -Encoding UTF8

    Write-Host "[OK] Default Dockerfile created." -ForegroundColor Green
} else {
    Write-Host "[OK] Dockerfile already exists." -ForegroundColor Green
}

# Try building the image
Write-Host "[Info] Building Docker image '$ImageName'..." -ForegroundColor Cyan
try {
    docker build -t $ImageName .
    Write-Host "[Success] Docker image '$ImageName' built successfully." -ForegroundColor Green
} catch {
    Write-Host "[Error] Docker build failed: $_" -ForegroundColor Red
    exit 1
}
