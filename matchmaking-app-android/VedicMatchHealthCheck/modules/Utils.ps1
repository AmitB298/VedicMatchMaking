function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO"  { "White" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        Default { "Gray" }
    }
    Write-Host "[$time] [$Level] $Message" -ForegroundColor $color

    $logPath = Join-Path $PSScriptRoot "..\logs\healthcheck.log"
    "$time [$Level] $Message" | Out-File -FilePath $logPath -Append -Encoding UTF8
}

function Log-Info {
    param ([string]$Message)
    Write-Log -Message $Message -Level "INFO"
}

function Log-Warning {
    param ([string]$Message)
    Write-Log -Message $Message -Level "WARNING"
}

function Log-Error {
    param ([string]$Message)
    Write-Log -Message $Message -Level "ERROR"
}

function Assert-FileExists {
    param ([string]$Path)
    if (-Not (Test-Path -Path $Path -PathType Leaf)) {
        Log-Error "❌ Required file missing: $Path"
        throw "File not found: $Path"
    } else {
        Log-Info "✅ Verified file exists: $Path"
    }
}

function Assert-DirectoryExists {
    param ([string]$Path)
    if (-Not (Test-Path -Path $Path -PathType Container)) {
        Log-Error "❌ Required directory missing: $Path"
        throw "Directory not found: $Path"
    } else {
        Log-Info "✅ Verified directory exists: $Path"
    }
}
