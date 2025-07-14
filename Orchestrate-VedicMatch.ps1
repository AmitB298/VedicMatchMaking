<#
.SYNOPSIS
  Orchestrates creation of Node, Python, React, Android services for VedicMatchMaking

.PARAMETER All
  Run all scaffolds in order

.PARAMETER Node
  Only run Node.js Backend scaffold

.PARAMETER Python
  Only run Python Kundli Service scaffold

.PARAMETER React
  Only run React Web scaffold

.PARAMETER Android
  Only run Android scaffold

.PARAMETER RootPath
  Root directory for scaffolding
#>

param(
    [switch]$All,
    [switch]$Node,
    [switch]$Python,
    [switch]$React,
    [switch]$Android,
    [string]$RootPath = (Get-Location).Path
)

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Run-SubScript {
    param (
        [string]$ScriptPath,
        [string]$Description
    )
    if (-not (Test-Path $ScriptPath)) {
        Write-Log "❌ Sub-script not found: $ScriptPath" "ERROR"
        return
    }

    try {
        & $ScriptPath -RootPath $RootPath
        Write-Log "✅ $Description completed successfully." "SUCCESS"
    } catch {
        Write-Log ("❌ Error running ${Description}: " + $_.Exception.Message) "ERROR"
    }
}

Write-Log "------------------------------------------------------------"
Write-Log "✅ VedicMatchmaking Advanced Orchestrator STARTED"
Write-Log "------------------------------------------------------------"
Write-Log "📂 Root Path: $RootPath"

if ($All -or $Node) {
    Run-SubScript "$PSScriptRoot\Scaffold-NodeBackend.ps1" "Node.js Backend"
}
if ($All -or $Python) {
    Run-SubScript "$PSScriptRoot\Scaffold-PythonKundli.ps1" "Python Kundli Service"
}
if ($All -or $React) {
    Run-SubScript "$PSScriptRoot\Scaffold-ReactWeb.ps1" "React Web Frontend"
}
if ($All -or $Android) {
    Run-SubScript "$PSScriptRoot\Scaffold-AndroidModule.ps1" "Android App Module"
}

Write-Log "------------------------------------------------------------"
Write-Log "✅ Orchestration Completed"
Write-Log "------------------------------------------------------------"
