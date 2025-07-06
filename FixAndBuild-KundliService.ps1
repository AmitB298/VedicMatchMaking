# FixAndBuild-KundliService.ps1
$ServicePath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli\kundli-service"
$PackageJsonPath = Join-Path $ServicePath "package.json"
$DockerfilePath = Join-Path $ServicePath "Dockerfile"
$ImageName = "kundli-service"

Set-Location $ServicePath

# Ensure package.json exists
if (-not (Test-Path $PackageJsonPath)) {
    Write-Host "[Error] package.json not found!" -ForegroundColor Red
    exit 1
}

# Read 'main' entry
$json = Get-Content $PackageJsonPath -Raw | ConvertFrom-Json
$MainFile = $json.main
if (-not $MainFile) {
    Write-Host "[Warning] No 'main' field found in package.json. Defaulting to 'index.js'" -ForegroundColor Yellow
    $MainFile = "index.js"
}

$MainPath = Join-Path $ServicePath $MainFile
if (-not (Test-Path $MainPath)) {
    Write-Host "`n[Error] '$MainFile' (as specified in package.json) does not exist!" -ForegroundColor Red

    $jsFiles = Get-ChildItem *.js | Select-Object -ExpandProperty Name
    if ($jsFiles.Count -eq 0) {
        Write-Host "[Fatal] No .js files found to use as entry point." -ForegroundColor Red
        exit 1
    }

    Write-Host "`nAvailable JS files:" -ForegroundColor Yellow
    $i = 1
    foreach ($file in $jsFiles) {
        Write-Host "[$i] $file"
        $i++
    }

    $choice = Read-Host "`nSelect the correct entry file by number"
    $selectedFile = $jsFiles[[int]$choice - 1]

    $action = Read-Host "`nDo you want to [1] update package.json or [2] rename '$selectedFile' to '$MainFile'? (enter 1 or 2)"
    
    if ($action -eq "1") {
        $json.main = $selectedFile
        $json | ConvertTo-Json -Depth 5 | Set-Content $PackageJsonPath -Encoding UTF8
        Write-Host "[✔] Updated package.json 'main' to $selectedFile" -ForegroundColor Green
        $MainFile = $selectedFile
    } elseif ($action -eq "2") {
        Rename-Item $selectedFile $MainFile
        Write-Host "[✔] Renamed $selectedFile to $MainFile" -ForegroundColor Green
    } else {
        Write-Host "[Cancelled] Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Rebuild Dockerfile
Write-Host "`n[Info] Rewriting Dockerfile with entry '$MainFile'" -ForegroundColor Cyan
@"
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 5000
CMD ["node", "$MainFile"]
"@ | Set-Content $DockerfilePath -Encoding UTF8

# Build Docker Image
Write-Host "`n[Info] Building Docker image '$ImageName'..." -ForegroundColor Cyan
try {
    docker build -t $ImageName .
    Write-Host "[✔] Docker image '$ImageName' built successfully." -ForegroundColor Green
} catch {
    Write-Host "[✘] Docker build failed: $_" -ForegroundColor Red
    exit 1
}
