param(
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "🐳 Kundli Service Docker Build & Run Automation"
Write-Host "------------------------------------------------------------"

# Ask if path not given
if (-not $ServicePath) {
    $ServicePath = Read-Host "Enter the full path to your Kundli service folder"
}

# Validate path
if (!(Test-Path $ServicePath)) {
    Write-Host "❌ ERROR: Folder does not exist: $ServicePath" -ForegroundColor Red
    exit 1
}

# Change directory
Set-Location $ServicePath
Write-Host "📂 Working directory: $ServicePath"

# Define names
$imageName = "kundli-service"
$containerName = "kundli-service-container"

# Build Docker image
Write-Host "🐳 Building Docker image: $imageName ..."
docker build -t $imageName . 

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: Docker build failed." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker image built: $imageName"

# Check if container exists
$existing = docker ps -a --filter "name=$containerName" --format "{{.ID}}"

if ($existing) {
    Write-Host "⚠️ Stopping existing container: $containerName"
    docker stop $containerName | Out-Null
    Write-Host "🗑️ Removing existing container: $containerName"
    docker rm $containerName | Out-Null
}

# Run new container
Write-Host "🚀 Running container: $containerName on port 5000"
docker run -d -p 5000:5000 --name $containerName $imageName

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: Docker run failed." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Container started: $containerName"

# Show running containers
Write-Host "------------------------------------------------------------"
Write-Host "📜 Currently running containers:"
docker ps
Write-Host "------------------------------------------------------------"
Write-Host "✅ All done. Your Kundli API is available at http://localhost:5000"
Write-Host "------------------------------------------------------------"
