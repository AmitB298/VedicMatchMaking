<#
.SYNOPSIS
  Configures API Base URL for both web and Android frontends.
.DESCRIPTION
  - Updates .env for React web app.
  - Updates api.properties for Android app.
  - Helps sync both to the same backend.
#>

param (
    [string]$BackendUrl
)

if (-not $BackendUrl) {
    $BackendUrl = Read-Host "Enter your backend API URL (e.g. http://localhost:5000/api/v1)"
}

Write-Host ""
Write-Host "Configuring Web Frontend (.env)..." -ForegroundColor Cyan
$webEnvPath = "matchmaking-app-web\.env"
$webEnvContent = @(
    "REACT_APP_API_URL=$BackendUrl"
)
Set-Content -Path $webEnvPath -Value $webEnvContent -Encoding UTF8
Write-Host ("Updated: {0}" -f $webEnvPath) -ForegroundColor Green

Write-Host ""
Write-Host "Configuring Android Frontend (api.properties)..." -ForegroundColor Cyan
$androidConfigPath = "matchmaking-app-android\api.properties"
$androidConfigContent = @(
    "API_BASE_URL=$BackendUrl"
)
Set-Content -Path $androidConfigPath -Value $androidConfigContent -Encoding UTF8
Write-Host ("Updated: {0}" -f $androidConfigPath) -ForegroundColor Green

Write-Host ""
Write-Host "All configurations updated successfully!" -ForegroundColor Green
Write-Host "Reminder: Restart your frontend dev servers to pick up changes." -ForegroundColor Yellow
