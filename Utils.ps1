# Utils.ps1 for HealthCheck

$global:CheckResults = @()

function Log-Info {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [INFO] $Message"
}

function Log-Warning {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [WARNING] $Message"
}

function Log-Error {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [ERROR] $Message"
}

function Assert-FileExists {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Log-Error "❌ Required file not found: $Path"
        throw "Required file missing: $Path"
    }
    Log-Info "✅ Verified file exists: $Path"
}

function Assert-DirectoryExists {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Log-Error "❌ Required directory not found: $Path"
        throw "Required directory missing: $Path"
    }
    Log-Info "✅ Verified directory exists: $Path"
}

function Record-Result {
    param(
        [string]$Check,
        [string]$Status,
        [string]$Details
    )
    $global:CheckResults += @{
        check   = $Check
        status  = $Status
        details = $Details
    }
}

function Save-Report {
    param (
        [string]$Path = (Join-Path $PSScriptRoot "..\reports\healthcheck-summary.json")
    )
    if ($global:CheckResults) {
        $json = $global:CheckResults | ConvertTo-Json -Depth 5
        Set-Content -Path $Path -Value $json -Encoding UTF8
        Log-Info "✅ Healthcheck summary saved to $Path"
    } else {
        Log-Warning "⚠️ No health check results to save."
    }
}
