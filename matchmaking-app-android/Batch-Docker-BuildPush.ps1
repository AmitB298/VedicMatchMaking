param(
    [string]$Namespace = "",
    [string]$Version = "1.0.0",
    [string[]]$Services = @("web", "backend"),
    [switch]$Push
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Batch Docker Build & Push Script"
Write-Host "------------------------------------------------------------"
Write-Host "🕒 Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""
Write-Host "📂 Working Directory: $PWD"
Write-Host "✅ Target Docker Hub Namespace: $Namespace"
Write-Host "✅ Target Version Tag: $Version"
Write-Host "✅ Services: $($Services -join ', ')"
Write-Host "✅ Push: $($Push.IsPresent)"
Write-Host "------------------------------------------------------------"

# 0. Validate Docker
try {
    docker version | Out-Null
} catch {
    Write-Error "❌ Docker CLI not found or not working. Install Docker Desktop."
    exit 1
}
try {
    docker info | Out-Null
} catch {
    Write-Error "❌ Docker daemon not running. Start Docker Desktop."
    exit 1
}
Write-Host "✔️ Docker CLI and daemon are ready."
Write-Host "------------------------------------------------------------"

foreach ($service in $Services) {
    Write-Host "⚙️ Processing service: $service"

    $servicePath = Join-Path $PWD $service
    if (-not (Test-Path $servicePath)) {
        Write-Warning "⚠️ Service folder not found. Creating: $service"
        New-Item -ItemType Directory -Path $servicePath | Out-Null
    }

    Set-Location $servicePath

    # 1. Ensure Dockerfile
    $dockerfilePath = Join-Path $servicePath "Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "✅ No Dockerfile found. Generating default production-ready Dockerfile..."
        @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
CMD ["node", "server.js"]
"@ | Set-Content $dockerfilePath
    }

    # 2. Ensure .dockerignore
    $dockerignorePath = Join-Path $servicePath ".dockerignore"
    if (-not (Test-Path $dockerignorePath)) {
        Write-Host "✅ No .dockerignore found. Generating default..."
        @"
node_modules
npm-debug.log
Dockerfile
*.md
"@ | Set-Content $dockerignorePath
    }

    # 3. Ensure package.json
    $packageJsonPath = Join-Path $servicePath "package.json"
    $packageLockPath = Join-Path $servicePath "package-lock.json"
    if (-not (Test-Path $packageJsonPath)) {
        Write-Host "✅ No package.json found. Generating minimal Express app..."
        @"
{
  "name": "$service",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
"@ | Set-Content $packageJsonPath

        npm install --package-lock-only
    }

    # 4. Ensure server.js
    $serverJsPath = Join-Path $servicePath "server.js"
    if (-not (Test-Path $serverJsPath)) {
        Write-Host "✅ No server.js found. Creating minimal Express server..."
        @"
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => res.send('✅ $service service is running!'));
app.listen(PORT, () => console.log('Server running on port', PORT));
"@ | Set-Content $serverJsPath
    }

    # 5. Build
    $hubTag = "${Namespace}/${service}:${Version}"
    Write-Host "🚀 Building image: $hubTag"
    try {
        docker build -t $hubTag . | Write-Host
        Write-Host "✅ Build succeeded: $hubTag"
    } catch {
        Write-Warning "❌ Build failed for $service. Skipping."
        Set-Location ..
        continue
    }

    # 6. Push
    if ($Push.IsPresent) {
        Write-Host "📤 Pushing $hubTag to Docker Hub..."
        try {
            docker push $hubTag | Write-Host
            Write-Host "✅ Pushed to Docker Hub: $hubTag"
        } catch {
            Write-Warning "❌ Push failed for $hubTag."
        }
    } else {
        Write-Host "➡️ Push disabled in config. Skipping push for $hubTag."
    }

    Set-Location ..
    Write-Host "✅ Done with $service"
    Write-Host "------------------------------------------------------------"
}

Write-Host "✅ All services processed."
Write-Host "✅ All images have been built and pushed (if requested)."
Write-Host "------------------------------------------------------------"
