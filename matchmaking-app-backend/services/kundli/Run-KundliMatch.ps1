# Run-KundliMatch.ps1
[CmdletBinding()]
param (
    [string]$PythonCmd = "python",
    [string]$Script = "kundli_match_full.py",
    [string]$EpheDir = "swiss_ephe",
    [string]$EpheFile = "seas_18.se1"
)

$ErrorActionPreference = "Stop"
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param([string]$msg, [string]$level = "Info")
    $color = switch ($level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Success" { "Green" }
        "Info" { "White" }
        default { "Gray" }
    }
    Write-Host "[$currentTime] [$level] $msg" -ForegroundColor $color
}

Write-Log "🚀 Starting Kundli match automation..."

# Step 1: Check script exists
if (-not (Test-Path -Path $Script)) {
    Write-Log "❌ Script '$Script' not found in current directory." -Level "Error"
    exit 1
}

# Step 2: Check ephemeris file
$ephePath = Join-Path -Path $EpheDir -ChildPath $EpheFile
if (-not (Test-Path -Path $ephePath)) {
    Write-Log "📥 Ephemeris data not found. Downloading..."
    if (-not (Test-Path -Path $EpheDir)) {
        New-Item -Path $EpheDir -ItemType Directory -Force | Out-Null
    }
    $epheUrl = "https://www.astro.com/ftp/swisseph/ephe/$EpheFile"
    try {
        Invoke-WebRequest -Uri $epheUrl -OutFile $ephePath
        Write-Log "✅ Ephemeris data downloaded successfully." -Level "Success"
    } catch {
        Write-Log "❌ Failed to download ephemeris data: $_" -Level "Error"
        exit 1
    }
} else {
    Write-Log "✅ Ephemeris data is present."
}

# Step 3: Run the Python script
Write-Log "⏳ Running $Script..."
try {
    $output = & $PythonCmd $Script
    Write-Log "✅ Script ran successfully. Parsing output..." -Level "Success"
    $json = $output | ConvertFrom-Json

    $maxPoints = @{
        "Varna" = 1
        "Vashya" = 2
        "Tara" = 3
        "Yoni" = 4
        "Graha Maitri" = 5
        "Gana" = 6
        "Bhakoot" = 7
        "Nadi" = 8
    }

    Write-Host ""
    Write-Log "🎯 Match Results:" -Level "Info"

    foreach ($k in $json.scores.PSObject.Properties.Name) {
        $v = $json.scores.$k
        $max = $maxPoints[$k]
        $emoji = if ($v -eq 0) {
            "❌"
        } elseif ($v -ge [math]::Round(0.8 * $max, 2)) {
            "✅"
        } else {
            "⚠️"
        }
        Write-Host "  ${k}: ${v} / ${max} ${emoji}"
    }

    Write-Host ""
    Write-Host "🔢 Total Gunas: $($json.total_score)/36"
    Write-Host "🔥 Mangal Dosha: Person 1: $(if ($json.mangal_dosha.person1) {'Yes'} else {'No'}) | Person 2: $(if ($json.mangal_dosha.person2) {'Yes'} else {'No'})"
    Write-Host "💑 Compatible (Mangal): $($json.mangal_dosha.compatible)"

    Write-Host "🐍 Kaal Sarp Dosha: Person 1: $(if ($json.kaal_sarp_dosha.person1) {'Yes'} else {'No'}) | Person 2: $(if ($json.kaal_sarp_dosha.person2) {'Yes'} else {'No'})"
    Write-Host "🧠 Dasha-Koota Score: $($json.dasha_koota_score) / 3"
    Write-Host "🧾 Verdict: $($json.verdict)"

} catch {
    Write-Log "❌ Script execution failed: $_" -Level "Error"
    exit 1
}

Write-Log "✅ Kundli match automation complete." -Level "Success"
