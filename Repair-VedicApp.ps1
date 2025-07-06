<#
.SYNOPSIS
    Repairs broken backend root route, frontend startup, and Flask verifier server.

.DESCRIPTION
    Fixes critical issues:
    - Ensures app.listen and root route exist in backend/server.js
    - Ensures Vite dev server runs on frontend
    - Ensures Flask app.run is present
    - Regenerates Dockerfiles if missing or invalid

.EXAMPLE
    .\Repair-VedicApp.ps1
#>

function Fix-BackendServer {
    $path = ".\matchmaking-app-backend\server.js"
    if (-not (Test-Path $path)) {
        Write-Warning "❌ Missing server.js"
        return
    }

    $code = Get-Content $path -Raw
    $fixed = $false

    if ($code -notmatch "const\s+express\s*=") {
        $code = "const express = require('express');`nconst app = express();`n" + $code
        $fixed = $true
    }

    if ($code -notmatch "app\.get\('/'\s*,") {
        $code += "`napp.get('/', (req, res) => res.send('✅ Vedic Matchmaking Backend Running'));"
        $fixed = $true
    }

    if ($code -notmatch "app\.listen") {
        $code += "`napp.listen(process.env.PORT || 3000, () => console.log('✅ Server running'));"
        $fixed = $true
    }

    if ($fixed) {
        $code | Set-Content $path
        Write-Host "✅ Fixed backend server.js" -ForegroundColor Green
    } else {
        Write-Host "✅ backend server.js already valid" -ForegroundColor Yellow
    }
}

function Fix-FrontendWeb {
    $pkgPath = ".\matchmaking-app-web\package.json"
    $viteConfig = ".\matchmaking-app-web\vite.config.js"
    if (-not (Test-Path $pkgPath)) {
        Write-Warning "❌ Missing package.json in matchmaking-app-web"
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
        $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
        Write-Host "✅ Updated Vite dev/start scripts" -ForegroundColor Green
    } else {
        Write-Host "✅ Vite scripts already set" -ForegroundColor Yellow
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
        Write-Host "✅ Created vite.config.js with host binding" -ForegroundColor Green
    }

    $dockerPath = ".\matchmaking-app-web\Dockerfile"
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
        Write-Host "✅ Created web Dockerfile for Vite dev" -ForegroundColor Green
    }
}

function Fix-PhotoVerifier {
    $path = ".\matchmaking-app-backend\services\verification\photo_verifier.py"
    $dockerPath = ".\matchmaking-app-backend\services\verification\Dockerfile"
    if (-not (Test-Path $path)) {
        Write-Warning "❌ Missing photo_verifier.py"
        return
    }

    $content = Get-Content $path -Raw
    if ($content -notmatch "if __name__\s*==\s*['""]__main__['""]") {
        Add-Content $path "`nif __name__ == '__main__':`n    app.run(host='0.0.0.0', port=5000)"
        Write-Host "✅ Added app.run(...) to photo_verifier.py" -ForegroundColor Green
    } else {
        Write-Host "✅ app.run already present in photo_verifier.py" -ForegroundColor Yellow
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

# ---- RUN ALL REPAIRS ----
Write-Host "`n🛠️ Repairing Vedic Matchmaking app services..." -ForegroundColor Cyan
Fix-BackendServer
Fix-FrontendWeb
Fix-PhotoVerifier
Write-Host "`n✅ Repairs complete. Now run: .\Deploy-VedicApp.ps1" -ForegroundColor Green
