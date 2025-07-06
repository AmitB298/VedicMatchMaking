<#
.SYNOPSIS
    Full auto-fix and deployment for Vedic Matchmaking App.
#>

function Invoke-YamlFixer {
    $fixerScript = ".\Fix-DockerCompose.ps1"
    if (Test-Path $fixerScript) {
        Write-Host "`n🔧 Running YAML Fixer before deployment..." -ForegroundColor Cyan
        & $fixerScript
    } else {
        Write-Host "⚠️ Fix-DockerCompose.ps1 not found. Skipping YAML fix..." -ForegroundColor Yellow
    }
}

function Fix-Backend {
    $file = ".\matchmaking-app-backend\server.js"
    if (-not (Test-Path $file)) { Write-Host "❌ server.js not found" -ForegroundColor Red; return }
    $code = Get-Content $file -Raw
    $modified = $false
    if ($code -notmatch "app\.get\(\s*['\""]/['\"]") {
        $code += "`napp.get('/', (req, res) => res.send('✅ Vedic Matchmaking Backend Running'));"
        $modified = $true
    }
    if ($code -notmatch "app\.listen\(") {
        $code += "`napp.listen(process.env.PORT || 3000, () => console.log('✅ Server running on port 3000'));"
        $modified = $true
    }
    if ($modified) {
        $code | Set-Content $file
        Write-Host "✅ Fixed backend route and listen" -ForegroundColor Green
    } else {
        Write-Host "✅ Backend already configured" -ForegroundColor Yellow
    }
}

function Deploy-Stack {
    $clean = Read-Host "⚠️ Do you want to clean unused Docker resources? (y/n)"
    if ($clean -eq 'y') {
        Write-Host "🧹 Cleaning Docker..." -ForegroundColor DarkGray
        docker system prune -af --volumes
    }

    Write-Host "🔧 Building and starting services..." -ForegroundColor Cyan
    docker-compose up --build -d

    Start-Sleep -Seconds 10

    Write-Host "`n🔍 Running health checks..." -ForegroundColor Cyan
    Test-Service http://localhost:3000/ "Backend"
    Test-Service http://localhost:5173/ "Frontend"
    Test-Service http://localhost:5000/ "Verifier"
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

# ========================= EXECUTE ============================
Write-Host "`n🚀 Starting Full Auto-Fix & Deploy for Vedic Matchmaking App..." -ForegroundColor Cyan

Invoke-YamlFixer
Fix-Backend
Deploy-Stack

Write-Host "`n🎉 All done! App should now be running locally." -ForegroundColor Green
