<#
.SYNOPSIS
Removes app.py file from Kundli microservice

.DESCRIPTION
Safely checks if app.py exists in the Kundli service folder and deletes it. 
Provides clear output with success/failure messages.

.PARAMETER ServicePath
Path to the Kundli service folder.

.EXAMPLE
.\Remove-AppPy.ps1 -ServicePath "E:\VedicCouple\matchmaking-app-backend\services\kundli"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting app.py Remover..."
Write-Host "------------------------------------------------------------"

$appFile = Join-Path $ServicePath "app.py"

if (Test-Path $appFile) {
    Remove-Item $appFile -Force
    Write-Host "✅ app.py has been deleted from: $appFile"
} else {
    Write-Host "⚠️  No app.py file found at: $appFile"
}

Write-Host "------------------------------------------------------------"
Write-Host "✅ Done!"
