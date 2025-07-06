<#
.SYNOPSIS
    PowerShell script to detect and fix Vite 404 errors on localhost:5173.
#>

param (
    [string]$WebPath = "E:\VedicMatchMaking\matchmaking-app-web",
    [string]$DevServerUrl = "http://localhost:5173"
)

function Test-FileExists($path, $description) {
    if (-Not (Test-Path $path)) {
        Write-Warning "❌ Missing: $description at $path"
        return $false
    } else {
        Write-Host "✅ Found: $description"
        return $true
    }
}

function Check-ViteFiles {
    Write-Host "`n🔍 Checking essential files for Vite project..." -ForegroundColor Cyan
    $ok = $true
    $ok = $ok -and (Test-FileExists "$WebPath\index.html" "index.html")
    $ok = $ok -and (Test-FileExists "$WebPath\src\main.tsx" "src/main.tsx")
    $ok = $ok -and (Test-FileExists "$WebPath\src\App.tsx" "src/App.tsx")
    return $ok
}

function Check-ViteServer {
    Write-Host "`n🌐 Checking Vite dev server status..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $DevServerUrl -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200 -and $response.Content -match "<div id=.root.>") {
            Write-Host "✅ Vite is running and responding properly." -ForegroundColor Green
        } elseif ($response.StatusCode -eq 404) {
            Write-Warning "⚠️ Vite is running but returning 404. Likely causes:"
            Write-Host "   - Missing or broken index.html"
            Write-Host "   - React Router misconfigured"
            Write-Host "   - No route defined for '/'"
        } else {
            Write-Warning "⚠️ Unexpected response: $($response.StatusCode)"
        }
    } catch {
        Write-Error "❌ Could not connect to $DevServerUrl. Is Vite running?"
    }
}

function Check-ViteConfig {
    $viteConfigPath = "$WebPath\vite.config.ts"
    if (Test-Path $viteConfigPath) {
        Write-Host "`n🔍 Checking vite.config.ts base path..." -ForegroundColor Cyan
        $content = Get-Content $viteConfigPath
        $baseLine = $content | Select-String 'base\s*:\s*["''](.*?)["'']'
        if ($baseLine) {
            Write-Warning "⚠️ Vite config has a base path set: $($baseLine.Matches[0].Groups[1].Value)"
        } else {
            Write-Host "✅ No custom base path found in vite.config.ts"
        }
    } else {
        Write-Warning "⚠️ vite.config.ts not found"
    }
}

# MAIN
Write-Host "🧪 Vite Dev Server Diagnostic Script (React App)" -ForegroundColor Yellow

if (-Not (Test-Path $WebPath)) {
    Write-Error "Project path $WebPath not found. Please check the location."
    exit 1
}

$allGood = Check-ViteFiles

Check-ViteConfig
Check-ViteServer

if ($allGood) {
    Write-Host "`n🚀 All essential files present. If 404 persists, check routing inside App.tsx or React Router setup." -ForegroundColor Green
} else {
    Write-Error "`n❌ Vite cannot serve properly due to missing files. Please fix the above issues first."
}
