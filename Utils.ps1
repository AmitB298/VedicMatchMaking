<#
.SYNOPSIS
  Utility functions for VedicMatchHealthCheck
.DESCRIPTION
  - Logging with timestamps
  - Assertion helpers
  - Result recording
  - Report saving
#>

# Initialize global results
$global:CheckResults = @()

# Logging
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

# Assertions
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

# Result recording
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

# Save report
function Save-Report {
    param(
        [string]$HealthCheckRoot
    )

    if (-not $HealthCheckRoot) {
        $HealthCheckRoot = (Get-Location).Path
    }

    $reportsDir = Join-Path $HealthCheckRoot "reports"
    if (-not (Test-Path $reportsDir)) {
        New-Item -ItemType Directory -Path $reportsDir | Out-Null
        Log-Info "✅ Created reports directory at $reportsDir"
    }

    $reportPath = Join-Path $reportsDir "healthcheck-summary.json"
    if ($global:CheckResults.Count -gt 0) {
        $json = $global:CheckResults | ConvertTo-Json -Depth 5
        Set-Content -Path $reportPath -Value $json -Encoding UTF8
        Log-Info "✅ Healthcheck summary saved to $reportPath"
    } else {
        Log-Warning "⚠️ No health check results to save."
    }
}
