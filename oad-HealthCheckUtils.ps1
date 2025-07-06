<#
.SYNOPSIS
Loads the VedicMatchHealthCheck Utils.ps1 module robustly from anywhere in the repo.
.DESCRIPTION
Finds the HealthCheck module in the expected folder structure and dot-sources it, with clear logging.
#>

# --------------------------
# CONFIGURABLE
# --------------------------
$HealthCheckFolderName = "VedicMatchHealthCheck"
$UtilsFileName = "Utils.ps1"

# --------------------------
# 1️⃣ Determine script root
# --------------------------
$InvocationRoot = $PSScriptRoot
if (-not $InvocationRoot) {
    $InvocationRoot = (Get-Location).Path
}

Write-Host "🧭 Current Location: $InvocationRoot" -ForegroundColor Cyan

# --------------------------
# 2️⃣ Search for HealthCheck folder
# --------------------------
$healthCheckFolder = Get-ChildItem -Path $InvocationRoot -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $HealthCheckFolderName } | Select-Object -First 1

if (-not $healthCheckFolder) {
    Write-Host "❌ ERROR: Could not find '$HealthCheckFolderName' folder under $InvocationRoot" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found HealthCheck folder: $($healthCheckFolder.FullName)" -ForegroundColor Green

# --------------------------
# 3️⃣ Build path to Utils.ps1
# --------------------------
$utilsPath = Join-Path -Path $healthCheckFolder.FullName -ChildPath "modules\$UtilsFileName"

if (-not (Test-Path $utilsPath)) {
    Write-Host "❌ ERROR: $UtilsFileName not found at expected location: $utilsPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found Utils.ps1: $utilsPath" -ForegroundColor Green

# --------------------------
# 4️⃣ Import it (Dot-Source)
# --------------------------
try {
    . $utilsPath
    Write-Host "✅ Successfully loaded HealthCheck Utils module!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR importing Utils.ps1: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --------------------------
# 5️⃣ Confirm functions
# --------------------------
Write-Host "🧩 Available Utils functions:" -ForegroundColor Yellow
Get-Command -Module Function | Where-Object { $_.Name -match "^Log|^Assert" } | Format-Table Name, CommandType

Write-Host "✨ Done. Ready to run health checks." -ForegroundColor Cyan
