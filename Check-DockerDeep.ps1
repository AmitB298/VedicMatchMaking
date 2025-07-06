<#
.SYNOPSIS
    Deep-dive diagnostic for "docker daemon is not running" on Windows.
.DESCRIPTION
    - Verifies Docker CLI installed
    - Verifies Docker Desktop installed
    - Verifies Windows service
    - Verifies GUI is open
    - Checks WSL2 distros and versions
    - Checks docker-desktop backend
    - Runs docker info
    - Writes recommendations to log
.PARAMETER ProjectPath
    Path to your project folder (for writing log).
.EXAMPLE
    .\Check-DockerDeep.ps1 -ProjectPath "E:\VedicMatchMaking"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$LogFile = Join-Path $ProjectPath "docker-deep-diagnostics.log"
"📝 Docker Deep Diagnostics Log" | Out-File $LogFile
"Timestamp: $(Get-Date)" | Out-File $LogFile -Append
"Project Path: $ProjectPath" | Out-File $LogFile -Append
"-----------------------------------------------------" | Out-File $LogFile -Append

function Log {
    param([string]$Message)
    Write-Host $Message
    $Message | Out-File $LogFile -Append
}

function Section {
    param([string]$Title)
    $bar = "-" * 60
    Log "`n$bar"
    Log "✅ $Title"
    Log "$bar"
}

# 1️⃣ Check Docker CLI
Section "Checking Docker CLI"
try {
    $dockerVersion = docker --version
    Log "✔️ Docker CLI found: $dockerVersion"
} catch {
    Log "❌ Docker CLI is not installed. Install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
}

# 2️⃣ Check Docker Desktop Installed
Section "Checking Docker Desktop Installation"
$desktopPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $desktopPath) {
    Log "✔️ Docker Desktop executable found: $desktopPath"
} else {
    Log "❌ Docker Desktop is not installed. Install from https://www.docker.com/products/docker-desktop/"
    exit 1
}

# 3️⃣ Check com.docker.service
Section "Checking Docker Windows Service"
try {
    $service = Get-Service com.docker.service -ErrorAction Stop
    Log "✔️ Service Status: $($service.Status)"
    if ($service.Status -ne 'Running') {
        Log "❌ Service is not running. Trying to start..."
        Start-Service com.docker.service
        Start-Sleep -Seconds 5
        $service = Get-Service com.docker.service
        Log "✔️ Service restarted. Status: $($service.Status)"
    }
} catch {
    Log "❌ com.docker.service not found. Docker Desktop install may be corrupted."
    exit 1
}

# 4️⃣ Check if Docker Desktop GUI is running
Section "Checking Docker Desktop GUI Process"
$desktopProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if ($null -eq $desktopProcess) {
    Log "❌ Docker Desktop GUI is not running."
    Log "➡️ ACTION: Please launch Docker Desktop from the Start Menu manually."
} else {
    Log "✔️ Docker Desktop GUI is running (PID $($desktopProcess.Id))."
}

# 5️⃣ Check WSL2 distros
Section "Checking WSL2 Distros"
try {
    $wslList = wsl --list --verbose
    Log $wslList
} catch {
    Log "❌ Failed to run 'wsl --list --verbose'. Ensure WSL is installed."
}

# 6️⃣ Check if docker-desktop distro is running
Section "Checking docker-desktop WSL2 Distro State"
$dockerDesktopState = wsl --list --verbose | Select-String "docker-desktop"
if ($dockerDesktopState -match "Stopped") {
    Log "❌ 'docker-desktop' WSL distro is stopped."
    Log "➡️ ACTION: Run 'wsl --shutdown' and then restart Docker Desktop."
} elseif ($dockerDesktopState -match "Running") {
    Log "✔️ 'docker-desktop' WSL distro is running."
} else {
    Log "❌ 'docker-desktop' WSL distro not found."
    Log "➡️ ACTION: Ensure Docker Desktop is installed with WSL2 integration enabled."
}

# 7️⃣ Suggest WSL2 shutdown if stuck
Section "Optional Fix: Restart WSL2"
Log "You can restart WSL2 with:"
Log "    wsl --shutdown"
Log "Then restart Docker Desktop."

# 8️⃣ Run docker info
Section "Running docker info"
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect") {
        Log "❌ Docker daemon is not reachable:"
        Log $dockerInfo
        Log "➡️ ACTION: Ensure Docker Desktop is fully started and says 'Docker is running'."
    } else {
        Log "✔️ Docker daemon is responding:"
        Log $dockerInfo
    }
} catch {
    Log "❌ Failed to run 'docker info':"
    Log $_
}

# 9️⃣ Recommendations
Section "Final Recommendations"
Log "✅ Check the following in order:"
Log "1️⃣ Start Docker Desktop from Start Menu."
Log "2️⃣ Wait until it says 'Docker is running'."
Log "3️⃣ If stuck, run 'wsl --shutdown' in PowerShell, then restart Docker Desktop."
Log "4️⃣ Check WSL distros with 'wsl --list --verbose' and ensure 'docker-desktop' is running."
Log "5️⃣ Ensure Hyper-V is enabled if on Windows Pro:"
Log "    Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All"
Log "6️⃣ As last resort, use Docker Desktop → Troubleshoot → 'Reset to factory defaults'."

Log "`n✅ Diagnostics complete! See full log at: $LogFile"

