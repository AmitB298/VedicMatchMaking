<#
.SYNOPSIS
  Runs all healthchecks for VedicMatchMaking.
.DESCRIPTION
  - Locates HealthCheck folder
  - Loads Utils.ps1
  - Loads and runs all Check-* scripts
  - Records PASS/FAIL results
  - Saves JSON report
#>

param(
    [string]$RepoRootParam
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🧭 Starting VedicMatchHealthCheck - Run-AllHealthChecks.ps1"

# -------------------------------------
# 1️⃣ Resolve RepoRoot
# -------------------------------------
if ($PSScriptRoot) {
    $RepoRoot = $PSScriptRoot
}
elseif ($MyInvocation.MyCommand.Path) {
    $RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}
elseif ($RepoRootParam) {
    $RepoRoot = $RepoRootParam
}
else {
    $RepoRoot = (Get-Location).Path
}

Write-Host "ℹ️ Using RepoRoot: $RepoRoot"

# -------------------------------------
# 2️⃣ Initialize
# -------------------------------------
$ErrorCount = 0
$HealthCheckFolderName = "VedicMatchHealthCheck"
$HealthCheckRoot = $null

# -------------------------------------
# 3️⃣ Locate HealthCheck Folder
# -------------------------------------
$candidate = Join-Path $RepoRoot "matchmaking-app-android\$HealthCheckFolderName"

if (Test-Path $candidate) {
    $HealthCheckRoot = $candidate
}
else {
    Write-Host "🔎 Searching recursively..."
    $matches = Get-ChildItem -Path $RepoRoot -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $HealthCheckFolderName }

    if ($matches -and $matches.Count -gt 0) {
        $HealthCheckRoot = $matches[0].FullName
    }
    else {
        Write-Error "❌ Could not locate '$HealthCheckFolderName'"
        exit 1
    }
}

Write-Host "✅ HealthCheckRoot resolved: $HealthCheckRoot"

# -------------------------------------
# 4️⃣ Load Utils.ps1
# -------------------------------------
$utilsPath = Join-Path $HealthCheckRoot "modules\Utils.ps1"

if (-not (Test-Path $utilsPath)) {
    Write-Error "❌ Utils.ps1 not found at $utilsPath"
    exit 1
}

. $utilsPath

if (-not (Get-Command -Name Log-Info -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Log-Info missing in Utils.ps1"
    exit 1
}

Log-Info "✅ Loaded Utils.ps1 from $utilsPath"

# -------------------------------------
# 5️⃣ Load Config
# -------------------------------------
$configPath = Join-Path $HealthCheckRoot "configs\healthcheck-config.json"

try {
    Assert-FileExists $configPath
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    Log-Info "✅ Loaded config from $configPath"
}
catch {
    Log-Error "❌ Failed to load config: $($_.Exception.Message)"
    exit 1
}

# -------------------------------------
# 6️⃣ Ensure Reports Directory
# -------------------------------------
$reportsDir = Join-Path $HealthCheckRoot "reports"

try {
    Assert-DirectoryExists $reportsDir
}
catch {
    Log-Error "❌ Reports directory inaccessible: $($_.Exception.Message)"
    exit 1
}

# -------------------------------------
# 7️⃣ Start Logging
# -------------------------------------
Log-Info "🛠️ VedicMatchHealthCheck - Full Run Started"

# -------------------------------------
# 8️⃣ Load Check-* Scripts
# -------------------------------------
$modulesDir = Join-Path $HealthCheckRoot "modules"
$checkScripts = @(Get-ChildItem -Path $modulesDir -Filter "Check-*.ps1" -File -ErrorAction SilentlyContinue)

if (-not $checkScripts -or $checkScripts.Count -eq 0) {
    Log-Warning "⚠️ No Check-*.ps1 scripts found in $modulesDir"
}
else {
    foreach ($script in $checkScripts) {
        Log-Info "⚙️ Loading $($script.Name)"
        try {
            . $script.FullName
        }
        catch {
            Log-Error "❌ Error loading $($script.Name): $($_.Exception.Message)"
            $ErrorCount++
        }
    }
}

# -------------------------------------
# 9️⃣ Run Check-* Functions
# -------------------------------------
$checkFunctions = @(Get-Command -CommandType Function | Where-Object { $_.Name -like "Check-*" })

if (-not $checkFunctions -or $checkFunctions.Count -eq 0) {
    Log-Warning "⚠️ No Check-* functions found to run."
}
else {
    foreach ($func in $checkFunctions) {
        Log-Info "🚀 Running $($func.Name)"
        try {
            & $func.Name -Config $config
            if (Get-Command -Name Record-Result -ErrorAction SilentlyContinue) {
                Record-Result -Check $func.Name -Status "PASS" -Details "Success"
            }
        }
        catch {
            Log-Error "❌ Error in $($func.Name): $($_.Exception.Message)"
            $ErrorCount++
            if (Get-Command -Name Record-Result -ErrorAction SilentlyContinue) {
                Record-Result -Check $func.Name -Status "FAIL" -Details "$($_.Exception.Message)"
            }
        }
    }
}

# -------------------------------------
# 🔟 Save Report
# -------------------------------------
try {
    if (Get-Command -Name Save-Report -ErrorAction SilentlyContinue) {
        Save-Report -HealthCheckRoot $HealthCheckRoot
    }
    else {
        Log-Warning "⚠️ Save-Report function not found."
    }
}
catch {
    Log-Error "❌ Error saving report: $($_.Exception.Message)"
    $ErrorCount++
}

# -------------------------------------
# ✅ Exit
# -------------------------------------
if ($ErrorCount -gt 0) {
    Log-Error "❌ HealthCheck completed with $ErrorCount error(s)."
    exit 1
}
else {
    Log-Info "✅ All health checks complete!"
    exit 0
}
