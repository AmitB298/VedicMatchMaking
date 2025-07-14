<#
.SYNOPSIS
Master orchestrator to scaffold all auth modules for VedicMatchmaking.

.PARAMETER All
Run all scaffolders in sequence.

.PARAMETER Node
Run only Node.js Auth scaffolder.

.PARAMETER Firebase
Run only Firebase Admin scaffolder.

.PARAMETER Frontend
Run only React Frontend scaffolder.

.PARAMETER Android
Run only Android scaffolder.

.PARAMETER Env
Run only EnvTemplates generator.

.PARAMETER Docker
Run only Docker builder.

.PARAMETER RootPath
Root project path to pass to sub-scripts.

.PARAMETER Version
Version tag for Docker images.

.PARAMETER Force
Force overwrite of existing files.
#>

param(
    [switch]$All,
    [switch]$Node,
    [switch]$Firebase,
    [switch]$Frontend,
    [switch]$Android,
    [switch]$Env,
    [switch]$Docker,
    [string]$RootPath = ".",
    [string]$Version = "latest",
    [switch]$Force
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "------------------------------------------------------------"
Write-Log "✅ VedicMatchmaking Advanced Orchestrator STARTED"
Write-Log "------------------------------------------------------------"
Write-Log "📂 Using RootPath: $RootPath"
if ($Force) { Write-Log "⚡ Force overwrite is ENABLED" "WARNING" }
Write-Log "------------------------------------------------------------"

# Helper to build standard argument list
function Build-Args {
    $args = @()
    if ($null -ne $RootPath) { $args += @("-RootPath", $RootPath) }
    if ($Force) { $args += "-Force" }
    return $args
}

# Helper to build Docker-specific arguments
function Build-DockerArgs {
    $args = @()
    if ($null -ne $RootPath) { $args += @("-RootPath", $RootPath) }
    if ($null -ne $Version)  { $args += @("-Version", $Version) }
    if ($Force) { $args += "-Force" }
    return $args
}

function Run-Step {
    param (
        [string]$Script,
        [string]$Description,
        [string[]]$ExtraArgs
    )
    Write-Log "▶️  Running: $Description"
    Write-Log "------------------------------------------------------------"
    try {
        & ".\$Script" @ExtraArgs
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ $Description completed successfully." "SUCCESS"
        } else {
            Write-Log "❌ $Description exited with code $LASTEXITCODE" "ERROR"
        }
    } catch {
        Write-Log "❌ Exception running $Description : $($_.Exception.Message)" "ERROR"
    }
    Write-Log "------------------------------------------------------------"
}

# Master switch logic
if ($All -or $Node) {
    Run-Step "Scaffold-NodeAuthModule.ps1" "Node.js Auth Module Scaffolder" (Build-Args)
}

if ($All -or $Firebase) {
    Run-Step "Scaffold-FirebaseAdmin.ps1" "Firebase Admin Scaffolder" (Build-Args)
}

if ($All -or $Frontend) {
    Run-Step "Scaffold-FrontendAuth.ps1" "React Frontend Auth Scaffolder" (Build-Args)
}

if ($All -or $Android) {
    Run-Step "Scaffold-AndroidAuth.ps1" "Android Auth Scaffolder" (Build-Args)
}

if ($All -or $Env) {
    Run-Step "Scaffold-EnvTemplates.ps1" "EnvTemplates Generator" (Build-Args)
}

if ($All -or $Docker) {
    Run-Step "Test-Build-Run-Docker.ps1" "Docker Build & Test Runner" (Build-DockerArgs)
}

Write-Log "✅ Orchestration Completed"
Write-Log "------------------------------------------------------------"
