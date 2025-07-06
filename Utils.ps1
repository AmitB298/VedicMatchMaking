<#
.SYNOPSIS
  Utility module for VedicMatchHealthCheck
.DESCRIPTION
  - Logging helpers
  - Assert file/dir exists
  - Record-Result function
  - Save-Report function
#>

# -------------------------------------
# Global Store for Results
# -------------------------------------
$global:CheckResults = @()

# -------------------------------------
# Logging Helpers
# -------------------------------------
function Log-Info {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [INFO] $Message"
}

function Log-Warning {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [WARNING] $Message"
}

function Log-Error {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [ERROR] $Message"
}

# -------------------------------------
# Assertions
# -------------------------------------
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

# -------------------------------------
# Record Results
# -------------------------------------
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

# -------------------------------------
# Save Report as JSON
# -------------------------------------
function Save-Report {
    param (
        [string]$Path
    )

    # Default path if not specified
    if (-not $Path) {
        $reportsFolder = Join-Path $PSScriptRoot "..\reports"
        if (-not (Test-Path $reportsFolder)) {
            New-Item -ItemType Directory -Path $reportsFolder | Out-Null
        }
        $Path = Join-Path $reportsFolder "healthcheck-summary.json"
    }

    if ($global:CheckResults -and $global:CheckResults.Count -gt 0) {
        $json = $global:CheckResults | ConvertTo-Json -Depth 5
        Set-Content -Path $Path -Value $json -Encoding UTF8
        Log-Info "✅ Healthcheck summary saved to $Path"
    }
    else {
        Log-Warning "⚠️ No health check results to save."
    }
}
