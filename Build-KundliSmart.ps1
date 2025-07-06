# Build-KundliSmart.ps1
# Automatically detects Node.js or Python and builds appropriate Dockerfile

$KundliPath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service"
$DockerfilePath = Join-Path $KundliPath "Dockerfile"
$PackageJson = Join-Path $KundliPath "package.json"
$Requirements = Join-Path $KundliPath "requirements.txt"
$ImageName = "kundli-service"

Write-Host "[Info] Checking Docker status..." -ForegroundColor Cyan
try {
    docker info > $null
    Write-Host "[OK] Docker is running." -ForegroundColor Green
} catch {
    Write-Host "[Error] Docker is not running. Start Docker Desktop and retry." -ForegroundColor Red
    exit 1
}

Set-Location $KundliPath

# Determine stack type
$IsNode = Test-Path $PackageJson
$IsPython = Test-Path $Requirements

if (-Not ($IsNode -or $IsPython)) {
    Write-Host "[Error] Could not determine if service is Node.js or Python. Missing both package.json and requirements.txt." -ForegroundColor Red
    exit 1
}

# Generate Dockerfile based on stack
Write-Host "[Info] Generating Dockerfile for detected stack..." -ForegroundColor Cyan
if ($IsNode) {
    Write-Host "[Detected] Node.js project" -ForegroundColor Yellow

    # Detect entry point
    $MainEntry = "index.js"
    try {
        $json = Get-Content $PackageJson | Out-String | ConvertFrom-Json
        if ($json.main) {
            $MainEntry = $json.main
        }
    } catch {
        Write-Host "[Warning] Could not parse main entry from package.json, using default: index.js" -ForegroundColor Yellow
    }

    @"
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 5000
CMD ["node", "$MainEntry"]
"@ | Set-Content -Path $DockerfilePath -Encoding UTF8

} elseif ($IsPython) {
    Write-Host "[Detected] Python Flask project" -ForegroundColor Yellow

    @"
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
CMD ["python", "main.py"]
"@ | Set-Content -Path $DockerfilePath -Encoding UTF8
}

# Build Docker image
Write-Host "[Info] Building Docker image '$ImageName'..." -ForegroundColor Cyan
try {
    docker build -t $ImageName .
    Write-Host "[Success] Docker image '$ImageName' built successfully." -ForegroundColor Green
} catch {
    Write-Host "[Error] Docker build failed: $_" -ForegroundColor Red
    exit 1
}
