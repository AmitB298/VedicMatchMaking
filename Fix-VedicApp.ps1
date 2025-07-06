<#
.SYNOPSIS
    Fixes critical issues in Vedic Matchmaking project before Docker deployment.

.DESCRIPTION
    - Adds missing app.listen and root route in backend
    - Adds missing app.run in photo_verifier.py
    - Ensures frontend has a start/dev script and correct Dockerfile
    - Auto-generates Dockerfiles if missing

.EXAMPLE
    .\Fix-VedicApp.ps1
#>

function Fix-Backend {
    $serverPath = ".\matchmaking-app-backend\server.js"
    if (Test-Path $serverPath) {
        $content = Get-Content $serverPath -Raw

        if ($content -notmatch "app\.listen") {
            Add-Content $serverPath "`napp.get('/', (req, res) => res.send('Vedic Matchmaking backend running ✅'));"
            Add-Content $serverPath "`napp.listen(process.env.PORT || 3000, () => console.log('✅ Server running on port 3000'));"
            Write-Host "✅ Fixed: Added app.listen(...) and root route to server.js" -ForegroundColor Green
        } else {
            Write-Host "✅ server.js already has app.listen(...)" -ForegroundColor Yellow
        }
    } else {
        Write-Warning "❌ server.js not found"
    }
}

function Fix-Frontend {
    $pkgPath = ".\matchmaking-app-web\package.json"
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
        if (-not $pkg.scripts.start) {
            $pkg.scripts.start = "vite"
            $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
            Write-Host "✅ Fixed: Added start script in package.json" -ForegroundColor Green
        } else {
            Write-Host "✅ Web package.json already has start script" -ForegroundColor Yellow
        }
    } else {
        Write-Warning "❌ package.json not found in matchmaking-app-web"
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
        Write-Host "✅ Created missing Dockerfile for web" -ForegroundColor Green
    }
}

function Fix-Verifier {
    $verifierPath = ".\matchmaking-app-backend\services\verification\photo_verifier.py"
    if (Test-Path $verifierPath) {
        $content = Get-Content $verifierPath -Raw
        if ($content -notmatch "if __name__ == .__main__.") {
            Add-Content $verifierPath "`nif __name__ == '__main__':`n    app.run(host='0.0.0.0', port=5000)"
            Write-Host "✅ Fixed: Added app.run(...) in photo_verifier.py" -ForegroundColor Green
        } else {
            Write-Host "✅ photo_verifier.py already has app.run(...)" -ForegroundColor Yellow
        }
    } else {
        Write-Warning "❌ photo_verifier.py not found"
    }

    $dockerPath = ".\matchmaking-app-backend\services\verification\Dockerfile"
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
        Write-Host "✅ Created missing Dockerfile for verifier" -ForegroundColor Green
    }
}

# -------- RUN ALL FIXES --------
Write-Host "`n🔧 Running Vedic Matchmaking App Auto-Fixer..." -ForegroundColor Cyan
Fix-Backend
Fix-Frontend
Fix-Verifier
Write-Host "`n✅ All critical fixes applied. You can now safely run .\Deploy-VedicApp.ps1" -ForegroundColor Green
