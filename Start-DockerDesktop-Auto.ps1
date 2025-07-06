<#
.SYNOPSIS
    Automatically detect and start Docker Desktop WSL2 VM if needed.
.DESCRIPTION
    - Checks if docker-desktop WSL2 VM is Stopped
    - Starts Docker Desktop if required
    - Waits for docker-desktop to be Running
    - Verifies with docker info
    - Logs everything
.PARAMETER ProjectPath
    The folder path where the log file will be saved
.EXAMPLE
    .\Start-DockerDesktop-Auto.ps1 -ProjectPath "E:\VedicMatchMaking"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$LogFile = Join-Path $ProjectPath "docker-startup-log.txt"
"📝 Docker Startup Automation Log" | Out-File $LogFile
"Timestamp: $(Get-Date)" | Out-File $LogFile -Append
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

# 2️⃣ Check docker-desktop WSL2 state
Section "Checking docker-desktop WSL2 Distro State"
try {
    $wslList = wsl --list --verbose
    Log $wslList
    $dockerDesktopLine = $wslList | Where-Object { $_ -match "docker-desktop" }
    if ($null -eq $dockerDesktopLine) {
        Log "❌ 'docker-desktop' WSL2 VM not found at all. Docker Desktop may not be installed or integrated with WSL2."
        Log "➡️ ACTION: Install Docker Desktop and enable WSL2 integration."
        exit 1
    }

    if ($dockerDesktopLine -match "Stopped") {
        Log "⚠️ 'docker-desktop' WSL2 VM is STOPPED."
        Log "➡️ ACTION: Need to start Docker Desktop to boot the VM."
        $NeedsStart = $true
    } elseif ($dockerDesktopLine -match "Running") {
        Log "✔️ 'docker-desktop' WSL2 VM is already RUNNING."
        $NeedsStart = $false
    } else {
        Log "❓ Unknown state for docker-desktop: $dockerDesktopLine"
        $NeedsStart = $true
    }
} catch {
    Log "❌ Error checking WSL distros."
    Log $_
    exit 1
}

# 3️⃣ Start Docker Desktop if needed
if ($NeedsStart) {
    Section "Starting Docker Desktop GUI"
    $dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    if ($null -eq $dockerProcess) {
        Log "ℹ️ Docker Desktop is not running. Starting it..."
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        Start-Sleep -Seconds 5
    } else {
        Log "✔️ Docker Desktop GUI process already running (PID(s): $($dockerProcess.Id -join ', '))"
    }

    # Wait loop for WSL2 VM to boot
    Section "Waiting for docker-desktop WSL2 VM to start"
    $MaxWait = 300
    $Interval = 5
    $Elapsed = 0
    do {
        Start-Sleep -Seconds $Interval
        $Elapsed += $Interval
        $current = wsl --list --verbose | Where-Object { $_ -match "docker-desktop" }
        Log "Polling docker-desktop WSL2 state: $current"

        if ($current -match "Running") {
            Log "✔️ docker-desktop WSL2 VM is now RUNNING after $Elapsed seconds."
            break
        }
    } while ($Elapsed -lt $MaxWait)

    if ($Elapsed -ge $MaxWait) {
        Log "❌ Timeout waiting for docker-desktop WSL2 VM to start."
        Log "➡️ Please manually open Docker Desktop and wait until it says 'Docker is running'."
        exit 1
    }
}

# 4️⃣ Run docker info
Section "Verifying with docker info"
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect") {
        Log "❌ Docker daemon is still not reachable:"
        Log $dockerInfo
        Log "➡️ ACTION: Ensure Docker Desktop says 'Docker is running'. You may need to reset Docker Desktop or restart your machine."
        exit 1
    } else {
        Log "✔️ Docker daemon is responding:"
        Log $dockerInfo
    }
} catch {
    Log "❌ Failed to run 'docker info':"
    Log $_
    exit 1
}

Section "✅ All checks complete!"
Log "✅ Docker is ready to use. See full log at: $LogFile"
