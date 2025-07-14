param(
    [Parameter(Mandatory=$true)]
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Kundli Service Deployment"
Write-Host "------------------------------------------------------------"

# Validate path
if (-Not (Test-Path $ServicePath)) {
    Write-Error "❌ ERROR: Service path not found: $ServicePath"
    exit 1
}

# Check for required files
$requiredFiles = @("Dockerfile", "requirements.txt", "kundli_service.py")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-Not (Test-Path (Join-Path $ServicePath $file))) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "❌ ERROR: Missing required files:"
    $missingFiles | ForEach-Object { Write-Host "   - $_" }
    exit 1
}

Write-Host "✅ All required files are present."
Write-Host "------------------------------------------------------------"

# Change to service directory
Set-Location $ServicePath

# Build Docker image
Write-Host "✅ Building Docker image..."
docker build -t kundli-service .

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ ERROR: Docker build failed."
    exit 1
}

Write-Host "✅ Docker image built successfully."
Write-Host "------------------------------------------------------------"

# Run container (optional: you might want to use docker-compose or different naming)
Write-Host "✅ Running Docker container..."
docker run -d --name kundli-service-container -p 5000:5000 kundli-service

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ ERROR: Docker run failed."
    exit 1
}

Write-Host "✅ Kundli Service deployed and running!"
Write-Host "------------------------------------------------------------"
