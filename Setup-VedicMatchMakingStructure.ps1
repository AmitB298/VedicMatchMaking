# Setup-VedicMatchMakingStructure.ps1
# Purpose: Create VedicMatchMakingStructure module files and prepare for Pester tests
# Usage: Run in PowerShell 7.5.1 from E:\VedicMatchMaking
# Compatibility: PowerShell 5.1 and 7.5.1

$ErrorActionPreference = 'Stop'
$modulePath = Join-Path -Path $PWD.Path -ChildPath "VedicMatchMakingStructure"

# Define files to create
$files = @(
    "VedicMatchMakingStructure.psm1",
    "VedicMatchMakingStructure.psd1",
    "Populate-DirectoryStructure.ps1",
    "Populate-DirectoryStructure.Tests.ps1"
)

Write-Host "Setting up VedicMatchMakingStructure module at $modulePath..." -ForegroundColor Cyan

# Validate script syntax
try {
    Write-Host "Validating script syntax..." -ForegroundColor Cyan
    $scriptContent = Get-Content -Path $PSCommandPath -Raw
    [ScriptBlock]::Create($scriptContent) | Out-Null
    Write-Host "Script syntax is valid." -ForegroundColor Green
} catch {
    Write-Host "Syntax error in script: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Install required modules
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Host "Installing Pester module..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -Scope CurrentUser -AllowClobber -MinimumVersion 5.0.0
}
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host "Installing PSScriptAnalyzer module..." -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -AllowClobber
}

# Create module directory
if (-not (Test-Path $modulePath)) {
    Write-Host "Creating directory $modulePath..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
}

# Create placeholder files
foreach ($file in $files) {
    $filePath = Join-Path -Path $modulePath -ChildPath $file
    $content = "# Placeholder for $file`n# Replace with full content from provided artifacts (artifact_id: 62918da2-fcd3-4401-aa22-7619cc2dd759)"
    if (-not (Test-Path $filePath)) {
        Write-Host "Creating placeholder file: $file" -ForegroundColor Green
        Set-Content -Path $filePath -Value $content -Encoding UTF8 -Force
    } else {
        Write-Host "Updating placeholder file: $file" -ForegroundColor Cyan
        Set-Content -Path $filePath -Value $content -Encoding UTF8 -Force
    }
}

# Verify file existence
Write-Host "Verifying module setup..." -ForegroundColor Cyan
$missingFiles = @()
foreach ($file in $files) {
    $filePath = Join-Path -Path $modulePath -ChildPath $file
    if (-not (Test-Path $filePath)) {
        Write-Host "Missing file: $file" -ForegroundColor Red
        $missingFiles += $file
    } else {
        Write-Host "Found file: $file" -ForegroundColor Green
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Setup failed. Missing files:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Placeholder files created at $modulePath" -ForegroundColor Cyan
Write-Host "Please replace the following files with full contents from the provided artifacts:" -ForegroundColor Yellow
$files | ForEach-Object { Write-Host "- $_" }
Write-Host "After replacing files, run Pester tests:" -ForegroundColor Cyan
Write-Host "Invoke-Pester -Path $modulePath\Populate-DirectoryStructure.Tests.ps1" -ForegroundColor Cyan