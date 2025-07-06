<#
.SYNOPSIS
    Auto-fixes and generates missing parts of the Vedic Matchmaking Docker setup.

.DESCRIPTION
    - Adds missing services to docker-compose.yml
    - Validates backend, frontend, and verifier setup
    - Creates Dockerfiles and config files if needed

.EXAMPLE
    .\Fix-VedicDocker.ps1
#>

function Ensure-DockerComposeEntry {
    $composePath = ".\docker-compose.yml"
    if (-not (Test-Path $composePath)) {
        Write-Warning "❌ docker-compose.yml not found!"
        return
    }

    $composeText = Get-Content $composePath -Raw
    $original = $composeText

    if ($composeText -notmatch "web:") {
        $composeText += @"
  web:
    container_name: vedicmatchmaking-web
    build:
      context: ./matchmaking-app-web
      dockerfile: Dockerfile
    ports:
      - "5173:5173"
    volumes:
      - ./matchmaking-app-web:/app
    working_dir: /app
    command: npm run dev
    depends_on:
      - api
"@
        Write-Host "✅ Added web service to docker-compose.yml" -ForegroundColor Green
    }

    if ($composeText -notmatch "verifier:") {
        $composeText += @"
  verifier:
    container_name: vedicmatchmaking-verifier
    build:
      context: ./matchmaking-app-backend/services/verification
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./matchmaking-app-backend/services/verification:/verifier
    working_dir: /verifier
    command: python photo_verifier.py
"@
        Write-Host "✅ Added verifier service to docker-compose.yml" -ForegroundColor Green
    }

    if ($composeText -ne $original) {
        Set-Content $composePath $composeText
    } else {
        Write-Host "✅ docker-compose.yml already includes all services" -ForegroundColor Yellow
    }
}

function Fix-Backend {
    $path = ".\matchmaking-app-backend\server.js"
    if (-not (Test-Path $path)) {
        Write-Warning "❌ server.js not found!"
        return
    }

    $code = Get-Content $path -Raw
    $changed = $false

    if ($code -notmatch "app\.get\('/')") {
        $code += "`napp.get('/', (req, res) => res.send('✅ Backend Running'));"
        $changed = $true
    }

    if ($code -notmatch "app\.listen") {
        $code += "`napp.listen(process.env.PORT || 3000, () => console.log('✅ Server started'));"
        $changed = $true
    }

    if ($changed) {
        $code | Set-Content $path
        Write-Host "✅ Fixed backend root and listen" -ForegroundColor Green
    } else {
        Write-Host "✅ Backend already correctly configured" -ForegroundColor Yellow
    }
}

function Fix-Frontend {
    $pkgPath = ".\matchmaking-app-web\package.json"
    $viteConfig = ".\matchmaking-app-web\vite.config.js"
    $dockerPath = ".\matchmaking-app-web\Dockerfile"

    if (-not (Test-Path $pkgPath)) {
        Write-Warning "❌ Frontend package.json not found"
        return
    }

    $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
    $changed = $false

    if (-not $pkg.scripts.start) {
        $pkg.scripts.start = "vite"
        $changed = $true
    }

    if (-not $pkg.scripts.dev) {
        $pkg.scripts.dev = "vite"
        $changed = $true
    }

    if ($changed) {
        $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
        Write-Host "✅ Patched package.json with Vite scripts" -ForegroundColor Green
    }

    if (-not (Test-Path $viteConfig)) {
        @"
import { defineConfig } from 'vite'
export default defineConfig({
  server: {
    host: true,
    port: 5173
  }
})
"@ | Set-Content $viteConfig
        Write-Host "✅ Created vite.config.js" -ForegroundColor Green
    }

    if (-not (Test-Path $dockerPath)) {
        @"
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
"@ | Set-Content $dockerPath
        Write-Host "✅ Created frontend Dockerfile" -ForegroundColor Green
    }
}

function Fix-Verifier {
    $verifierPath = ".\matchmaking-app-backend\services\verification\photo_verifier.py"
    $dockerPath = ".\matchmaking-app-backend\services\verification\Dockerfile"

    if (-not (Test-Path $verifierPath)) {
        Write-Warning "❌ photo_verifier.py not found"
        return
    }

    $verifierCode = Get-Content $verifierPath -Raw
    if ($verifierCode -notmatch "__main__") {
        Add-Content $verifierPath "`nif __name__ == '__main__':`n    app.run(host='0.0.0.0', port=5000)"
        Write-Host "✅ Added Flask app.run(...) to verifier" -ForegroundColor Green
    }

    if (-not (Test-Path $dockerPath)) {
        @"
FROM python:3.10-slim
WORKDIR /verifier
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "photo_verifier.py"]
"@ | Set-Content $dockerPath
        Write-Host "✅ Created verifier Dockerfile" -ForegroundColor Green
    }
}

# ================== MAIN ===================

Write-Host "`n🔧 Auto-fixing Docker Setup for Vedic Matchmaking..." -ForegroundColor Cyan

Ensure-DockerComposeEntry
Fix-Backend
Fix-Frontend
Fix-Verifier

Write-Host "`n✅ All fixes applied. Now run .\Deploy-VedicApp.ps1 to start the app." -ForegroundColor Green
