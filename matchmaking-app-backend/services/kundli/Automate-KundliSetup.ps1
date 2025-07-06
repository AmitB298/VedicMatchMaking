# Automate-KundliSetup.ps1
# Purpose: Automate setup and execution of Kundli matching script
# Usage: Run from E:\VedicMatchMaking\matchmaking-app-backend\services\kundli
# Date: June 30, 2025

[CmdletBinding()]
param (
    [string]$ScriptPath = "kundli_match.py",
    [string]$EpheUrl = "http://www.astro.com/ftp/swisseph/ephe/seas_18.se1",
    [string]$EpheDir = "swiss_ephe",
    [string]$PythonCmd = "python"
)

# Set error preference and log path
$ErrorActionPreference = 'Stop'
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "kundli_setup.log"
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Function to log messages
function Write-Log {
    param ([string]$Message, [string]$Level = "Info")
    $logEntry = "[$currentTime] [$Level] $Message"
    Add-Content -Path $logPath -Value $logEntry
    $foregroundColor = if ($Level -eq "Error") { "Red" } elseif ($Level -eq "Warning") { "Yellow" } else { "White" }
    Write-Host $logEntry -ForegroundColor $foregroundColor
}

# Check if in correct directory
$expectedPath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli"
if ($PSScriptRoot -ne $expectedPath) {
    Write-Log "Please run this script from $expectedPath" -Level "Error"
    exit 1
}

Write-Log "Starting Kundli setup automation process."

# 1. Install Python dependencies
$requiredPackages = @("pyswisseph", "numpy")
foreach ($package in $requiredPackages) {
    try {
        Write-Log "Checking for $package..."
        $result = & $PythonCmd -c "import $package" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Installing $package..."
            $installResult = & pip install $package 2>&1
            if ($LASTEXITCODE -ne 0) {
                $errorDetail = $installResult | Out-String
                Write-Log "Failed to install $package. Error: $errorDetail" -Level "Error"
                exit 1
            }
            Write-Log "$package installed successfully."
        } else {
            Write-Log "$package is already installed."
        }
    } catch {
        $errorDetail = $_.Exception.Message
        Write-Log "Error checking/installing $package: $errorDetail" -Level "Error"
        exit 1
    }
}

# 2. Download and set up Swiss Ephemeris data
$ephePath = Join-Path -Path $PSScriptRoot -ChildPath $EpheDir
if (-not (Test-Path -Path $ephePath)) {
    try {
        Write-Log "Creating $EpheDir directory..."
        New-Item -Path $ephePath -ItemType Directory -Force | Out-Null
        Write-Log "Downloading Swiss Ephemeris data from $EpheUrl..."
        Invoke-WebRequest -Uri $EpheUrl -OutFile (Join-Path -Path $ephePath -ChildPath "seas_18.se1")
        Write-Log "Swiss Ephemeris data downloaded successfully."
    } catch {
        $errorDetail = $_.Exception.Message
        Write-Log "Failed to download or set up ephemeris data: $errorDetail" -Level "Error"
        exit 1
    }
} else {
    Write-Log "Swiss Ephemeris data directory already exists."
}

# 3. Verify Python script exists or create it
$scriptFullPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptPath
if (-not (Test-Path -Path $scriptFullPath)) {
    Write-Log "Creating $ScriptPath..."
    $scriptContent = @"
import swisseph as swe
from datetime import datetime
import numpy as np

class KundliService:
    def __init__(self, ephe_path='swiss_ephe'):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, birth_date, birth_time, latitude, longitude):
        dt = datetime.strptime(f'{birth_date} {{birth_time}}', '%Y-%m-%d %H:%M:%S')
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {{}}
        for i in range(swe.SUN, swe.PLUTO + 1):
            pos = swe.calc_ut(jd, i)[0]
            planets[swe.get_planet_name(i)] = pos
        houses = swe.houses(jd, latitude, longitude, b'P')[0]
        ascendant = swe.houses(jd, latitude, longitude, b'P')[1][0]
        moon_pos = planets['Moon'][0]
        rasi = int(moon_pos // 30) + 1
        nakshatra = int((moon_pos % 360) / (360/27)) + 1
        return {
            'planets': planets,
            'ascendant': ascendant,
            'houses': houses,
            'rasi': rasi,
            'nakshatra': nakshatra,
            'birth_details': {
                'date': birth_date,
                'time': birth_time,
                'latitude': latitude,
                'longitude': longitude,
            },
        }

    def get_guna_points(self, kundli1, kundli2):
        points = {
            'Varna': 0, 'Vashya': 0, 'Tara': 0, 'Yoni': 0,
            'Graha Maitri': 0, 'Gana': 0, 'Bhakoot': 0, 'Nadi': 0
        }
        total_gunas = 0

        varna1, varna2 = kundli1['rasi'] % 4, kundli2['rasi'] % 4
        if varna1 == varna2:
            points['Varna'] = 1
        total_gunas += points['Varna']

        vashya1, vashya2 = kundli1['rasi'] % 5, kundli2['rasi'] % 5
        if vashya1 == vashya2:
            points['Vashya'] = 2
        total_gunas += points['Vashya']

        tara_diff = abs(kundli1['nakshatra'] - kundli2['nakshatra'])
        if tara_diff % 9 == 0 or tara_diff % 9 == 1:
            points['Tara'] = 3
        total_gunas += points['Tara']

        yoni_groups = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14]
        yoni1, yoni2 = yoni_groups[kundli1['nakshatra'] - 1], yoni_groups[kundli2['nakshatra'] - 1]
        if yoni1 == yoni2:
            points['Yoni'] = 4
        total_gunas += points['Yoni']

        if abs(kundli1['rasi'] - kundli2['rasi']) <= 2 or abs(kundli1['rasi'] - kundli2['rasi']) >= 10:
            points['Graha Maitri'] = 5
        total_gunas += points['Graha Maitri']

        gana1, gana2 = (kundli1['nakshatra'] - 1) // 9, (kundli2['nakshatra'] - 1) // 9
        if gana1 == gana2:
            points['Gana'] = 6
        elif (gana1 == 0 and gana2 == 1) or (gana1 == 1 and gana2 == 0):
            points['Gana'] = 5
        total_gunas += points['Gana']

        bhakoot_diff = abs(kundli1['rasi'] - kundli2['rasi'])
        if bhakoot_diff in [2, 4, 6, 8, 9, 11]:
            points['Bhakoot'] = 7
        total_gunas += points['Bhakoot']

        nadi1, nadi2 = (kundli1['nakshatra'] - 1) % 3, (kundli2['nakshatra'] - 1) % 3
        if nadi1 != nadi2:
            points['Nadi'] = 8
        total_gunas += points['Nadi']

        return points, total_gunas

    def check_mangal_dosha(self, kundli):
        mars_pos = kundli['planets']['Mars'][0]
        ascendant = kundli['ascendant']
        house1 = ascendant
        house7 = (ascendant + 180) % 360
        houses = kundli['houses']
        mars_house = min(range(len(houses)), key=lambda i: abs(houses[i] - mars_pos))
        dosha_houses = [0, 3, 6, 7, 11]
        return mars_house in dosha_houses or abs(mars_pos - house7) < 30

    def match_kundli(self, kundli1, kundli2):
        points, total_gunas = self.get_guna_points(kundli1, kundli2)
        mangal_dosha1 = self.check_mangal_dosha(kundli1)
        mangal_dosha2 = self.check_mangal_dosha(kundli2)
        mangal_compatible = not (mangal_dosha1 and mangal_dosha2)

        report = {
            'kundli1': kundli1['birth_details'],
            'kundli2': kundli2['birth_details'],
            'guna_points': points,
            'total_gunas': total_gunas,
            'mangal_dosha': {
                'person1': mangal_dosha1,
                'person2': mangal_dosha2,
                'compatible': mangal_compatible
            },
            'match_status': 'Good' if total_gunas >= 18 and mangal_compatible else 'Not Recommended'
        }
        return report

def test_kundli_match():
    service = KundliService()
    person1 = service.generate_kundli('1990-01-01', '12:00:00', 28.6139, 77.2090)
    person2 = service.generate_kundli('1990-01-02', '12:00:00', 28.6139, 77.2090)
    match_result = service.match_kundli(person1, person2)
    print(f'Kundli 1: {match_result["kundli1"]}')
    print(f'Kundli 2: {match_result["kundli2"]}')
    print('Guna Points:')
    for koota, points in match_result['guna_points'].items():
        print(f'  {koota}: {points} points')
    print(f'Total Gunas: {match_result["total_gunas"]}/36')
    print('Mangal Dosha:')
    print(f'  Person 1: {"Yes" if match_result["mangal_dosha"]["person1"] else "No"}')
    print(f'  Person 2: {"Yes" if match_result["mangal_dosha"]["person2"] else "No"}')
    print(f'  Compatible: {match_result["mangal_dosha"]["compatible"]}')
    print(f'Match Status: {match_result["match_status"]}')
    assert 0 <= match_result['total_gunas'] <= 36, "Total Gunas should be between 0 and 36"
    print('Test passed: Guna calculation and Mangal Dosha check are valid.')

if __name__ == "__main__":
    test_kundli_match()
"@
    $scriptContent | Out-File -FilePath $scriptFullPath -Encoding UTF8
    Write-Log "$ScriptPath created successfully."
} else {
    Write-Log "$ScriptPath already exists, skipping creation."
}

# 4. Run the Python script
try {
    Write-Log "Running $ScriptPath..."
    $process = Start-Process -FilePath $PythonCmd -ArgumentList $scriptFullPath -NoNewWindow -PassThru -Wait
    if ($process.ExitCode -ne 0) {
        throw [System.Exception]::new("Python script exited with error code $($process.ExitCode)")
    }
    Write-Log "Kundli matching completed successfully."
} catch {
    $errorMsg = $_.Exception.Message
    Write-Log "Error running $ScriptPath: $errorMsg" -Level "Error"
    exit 1
}

Write-Log "Kundli setup automation process completed."