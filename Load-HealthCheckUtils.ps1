<#
.SYNOPSIS
Loads the VedicMatchHealthCheck modules from anywhere in the repo
#>

Write-Host "🧭 Starting HealthCheck Utils Loader..."

# Discover HealthCheck folder automatically
$repoRoot = $PSScriptRoot
$healthCheckName = "VedicMatchHealthCheck"

# Find the folder
$matches = Get-ChildItem -Path $repoRoot -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -eq $healthCheckName
}

if (-not $matches) {
    Write-Error "❌ Could not locate '$healthCheckName' folder. Make sure it's in the repo."
    exit 1
}

$healthCheckRoot = $matches[0].FullName
$utilsPath = Join-Path $healthCheckRoot "modules\Utils.ps1"

if (-not (Test-Path $utilsPath)) {
    Write-Error "❌ Utils.ps1 not found in: $utilsPath"
    exit 1
}

Write-Host "✅ Found HealthCheck Utils.ps1 at $utilsPath"

# Import the Utils
. $utilsPath

Write-Host "✅ Successfully loaded HealthCheck Utils module!"
Write-Host "🧩 Available Utils functions:"
Get-Command -Module Function | Where-Object { $_.Name -like "Log-*" -or $_.Name -like "Assert-*" }
Write-Host "✨ Done. Ready to run health checks."
