<#
.SYNOPSIS
  Interactive project metadata collector for VedicMatchMaking.

.DESCRIPTION
  Prompts user for project configuration, validates inputs,
  and writes a JSON config file to project-info.json.

.NOTES
  Written to prevent crashes, with safe defaults and prompts.
#>

Write-Host "------------------------------------------------------------"
Write-Host "✅ Project Bootstrap Info Collector" -ForegroundColor Green
Write-Host "------------------------------------------------------------"
Write-Host "🕒 Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# Helper: Safe Prompt with Default
function Prompt-Default($Prompt, $Default) {
    $input = Read-Host "$Prompt (Default: $Default)"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    return $input.Trim()
}

# Project-level settings
$project = @{}

$project.ProjectName = Prompt-Default "Enter your Project Name" "VedicMatchMaking"
$project.DockerHubNamespace = Prompt-Default "Enter your Docker Hub Username (no slashes)" "amitbanerjee08111992"

# Validate Docker Hub Namespace
while ($project.DockerHubNamespace -match "[/:]" -or [string]::IsNullOrWhiteSpace($project.DockerHubNamespace)) {
    Write-Warning "❌ ERROR: Docker Hub Username cannot contain '/' or ':'."
    $project.DockerHubNamespace = Prompt-Default "Please enter a valid Docker Hub Username" "amitbanerjee08111992"
}

$project.Version = Prompt-Default "Enter default Docker Image Version" "1.0.0"

# Services
Write-Host ""
Write-Host "✅ Let's configure your services" -ForegroundColor Cyan
$servicesInput = Read-Host "Enter comma-separated service folders (e.g. web,backend,android) [Default: web,backend]"
if ([string]::IsNullOrWhiteSpace($servicesInput)) {
    $servicesInput = "web,backend"
}
$project.Services = $servicesInput.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

# Push by default?
$pushInput = Prompt-Default "Push images to Docker Hub automatically? (y/n)" "y"
$project.PushByDefault = $pushInput.ToLower() -eq "y"

# Android Emulator Options
Write-Host ""
Write-Host "✅ Android Emulator Configuration" -ForegroundColor Cyan
$project.AndroidEmulator = @{
    Enable = ($true -eq ((Prompt-Default "Enable Android Emulator integration? (y/n)" "n").ToLower() -eq "y"))
    EmulatorName = Prompt-Default "Android Emulator Name" "Pixel_6_API_34"
    BuildVariant = Prompt-Default "Android Build Variant" "debug"
}

# Web Dev Server
Write-Host ""
Write-Host "✅ Web Frontend Configuration" -ForegroundColor Cyan
$project.WebFrontend = @{
    Framework = Prompt-Default "Web Frontend Type (React, Angular, Vue, etc.)" "React"
    DevServerPort = Prompt-Default "Web Dev Server Port" "3000"
}

# Output file
$jsonPath = Join-Path $PSScriptRoot "project-info.json"

$project | ConvertTo-Json -Depth 5 | Out-File -Encoding UTF8 $jsonPath

Write-Host ""
Write-Host "✅ Project configuration saved to: $jsonPath" -ForegroundColor Green
Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ All Done!"
Write-Host "------------------------------------------------------------"
