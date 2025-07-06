Write-Host "`n🛠️ Fixing Express Dockerfile and restarting containers..." -ForegroundColor Cyan

# Step 1: Locate Dockerfile
$dockerfilePath = Get-ChildItem -Path . -Recurse -Filter "Dockerfile" | Where-Object {
    (Get-Content $_.FullName) -match "express"
} | Select-Object -First 1

if (-not $dockerfilePath) {
    Write-Host "❌ Express Dockerfile not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found Dockerfile: $($dockerfilePath.FullName)" -ForegroundColor Green

# Step 2: Ensure Dockerfile has proper config
$dockerfileContent = Get-Content $dockerfilePath.FullName
$fixedContent = @()

$hasWorkdir = $false
$hasCopy = $false
$hasDependencies = $false

foreach ($line in $dockerfileContent) {
    if ($line -match "WORKDIR /app") { $hasWorkdir = $true }
    if ($line -match "COPY . .") { $hasCopy = $true }
    if ($line -match "express" -or $line -match "npm install") { $hasDependencies = $true }
    $fixedContent += $line
}

if (-not $hasWorkdir) { $fixedContent += "WORKDIR /app" }
if (-not $hasCopy)    { $fixedContent += "COPY . ." }
if (-not $hasDependencies) {
    $fixedContent += "RUN npm install express cors mongodb"
}

# Save updated Dockerfile
Set-Content -Path $dockerfilePath.FullName -Value $fixedContent -Encoding UTF8
Write-Host "📝 Dockerfile fixed and saved." -ForegroundColor Green

# Step 3: Stop old containers
Write-Host "`n🧹 Stopping and removing old containers..." -ForegroundColor Yellow
docker-compose down

# Step 4: Rebuild
Write-Host "`n🔨 Rebuilding with Docker Compose..." -ForegroundColor Yellow
docker-compose build

# Step 5: Restart
Write-Host "`n🚀 Starting Docker Compose services..." -ForegroundColor Yellow
docker-compose up -d

# Step 6: Check route
Start-Sleep -Seconds 5
$response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -ErrorAction SilentlyContinue
if ($response.StatusCode -eq 200) {
    Write-Host "`n✅ Server responded with HTTP 200 at http://localhost:3000/" -ForegroundColor Green
} else {
    Write-Host "`n❌ Server did not respond with 200. Status: $($response.StatusCode)" -ForegroundColor Red
}
