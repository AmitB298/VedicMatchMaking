<#
.SYNOPSIS
    Fixes and deploys the Vedic Matchmaking application (Docker + Node + Vite + Flask).
.EXAMPLE
    .\FixAndDeploy-VedicApp.ps1
#>

function Fix-DockerCompose {
    $path = ".\docker-compose.yml"
    if (-not (Test-Path $path)) {
        Write-Host "❌ docker-compose.yml not found!" -ForegroundColor Red
        return
    }
    $yaml = Get-Content $path -Raw
    $original = $yaml

    if ($yaml -notmatch "web:") {
        $yaml += @"
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
        Write-Host "✅ Web service added to docker-compose.yml" -ForegroundColor Green
    }

    if ($yaml -notmatch "verifier:") {
        $yaml += @"
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
        Write-Host "✅ Verifier service added to docker-compose.yml" -ForegroundColor Green
    }

    if ($yaml -ne $original) {
        Set-Content $path $yaml
    } else {
        Write-Host "✅ docker-compose.yml already contains required services" -ForegroundColor Yellow
    }
}

function Fix-Backend {
    $file = ".\matchmaking-app-backend\server.js"
    if (-not (Test-Path $file)) {
        Write-Host "❌ server.js not found" -ForegroundColor Red
        return
    }

    $code = Get-Content $file -Raw
    $modified = $false

    if ($code -notmatch "app\.get\(\s*['""]/['""]\s*,") {
        $code += "`napp.get('/', (req, res) => res.send('✅ Vedic Matchmaking Backend Running'));"
        $modified = $true
    }

    if ($code -notmatch "app\.listen\(") {
        $code += "`napp.listen(process.env.PORT || 3000, () => console.log('✅ Server running on port 3000'));"
        $modified = $true
    }

    if ($modified) {
        Set-Content $file $code
        Write-Host "✅ Fixed backend route and listen" -ForegroundColor Green
    } else {
        Write-Host "✅ Backend already configured" -ForegroundColor Yellow
    }
}

function Fix-Frontend {
    $pkgPath = ".\matchmaking-app-web\package.json"
    $viteConfig = ".\matchmaking-app-web\vite.config.js"
    $dockerfile = ".\matchmaking-app-web\Dockerfile"

    if (-not (Test-Path $pkgPath)) {
        Write-Host "❌ package.json not found" -ForegroundColor Red
        return
    }

    $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
    $changed = $false

    if (-not $pkg.scripts.dev) {
        $pkg.scripts.dev = "vite"
        $changed = $true
    }

    if (-not $pkg.scripts.start) {
        $pkg.scripts.start = "vite"
        $changed = $true
    }

    if ($changed) {
        $pkg | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 $pkgPath
        Write-Host "✅ Patched package.json with start/dev scripts" -ForegroundColor Green
    }

    if (-not (Test-Path $viteConfig)) {
@"
import { defineConfig } from 'vite';
export default defineConfig({
  server: {
    host: true,
    port: 5173
  }
});
"@ | Set-Content $viteConfig
        Write-Host "✅ Created vite.config.js" -ForegroundColor Green
    }

    if (-not (Test-Path $dockerfile)) {
@"
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD [\"npm\", \"run\", \"dev\"]
"@ | Set-Content $dockerfile
        Write-Host "✅ Created frontend Dockerfile" -ForegroundColor Green
    }
}

function Fix-Verifier {
    $pyPath = ".\matchmaking-app-backend\services\verification\photo_verifier.py"
    $dockerPath = ".\matchmaking-app-backend\services\verification\Dockerfile"

    if (-not (Test-Path $pyPath)) {
        Write-Host "❌ photo_verifier.py not found" -ForegroundColor Red
        return
    }

    $code = Get-Content $pyPath -Raw
    if ($code -notmatch 'if\s+__name__\s*==\s*["'']__main__["'']') {
        Add-Content $pyPath "`nif __name__ == '__main__':`n    app.run(host='0.0.0.0', port=5000)"
        Write-Host "✅ Added Flask app.run(...) to verifier" -ForegroundColor Green
    }

    if (-not (Test-Path $dockerPath)) {
@"
FROM python:3.10-slim
WORKDIR /verifier
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD [\"python\", \"photo_verifier.py\"]
"@ | Set-Content $dockerPath
        Write-Host "✅ Created verifier Dockerfile" -ForegroundColor Green
    }
}

function Test-Service($url, $name) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
        if ($resp.StatusCode -eq 200) {
            Write-Host "✅ $name service is running at $url" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $name returned HTTP $($resp.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $name service is NOT reachable at $url" -ForegroundColor Red
    }
}

function Deploy-Stack {
    $clean = Read-Host "⚠️ Do you want to clean unused Docker resources? (y/n)"
    if ($clean -eq 'y') {
        Write-Host "🧹 Cleaning Docker..." -ForegroundColor Gray
        docker system prune -af --volumes
    }

    Write-Host "🔧 Building and starting services..." -ForegroundColor Cyan
    docker-compose up --build -d
    Start-Sleep -Seconds 10

    Write-Host "`n🔍 Running health checks..." -ForegroundColor Cyan
    Test-Service "http://localhost:3000/" "Backend"
    Test-Service "http://localhost:5173/" "Frontend"
    Test-Service "http://localhost:5000/" "Verifier"
}

# ==== MAIN ENTRY POINT ====
Write-Host "`n🚀 Starting Full Auto-Fix & Deploy for Vedic Matchmaking App..." -ForegroundColor Cyan

Fix-DockerCompose
Fix-Backend
Fix-Frontend
Fix-Verifier
Deploy-Stack

Write-Host "`n🎉 All done! App should now be running locally." -ForegroundColor Green
