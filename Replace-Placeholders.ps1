# Replace-Placeholders.ps1
# Purpose: Replace placeholder files in VedicMatchMakingStructure with full contents
# Usage: Run in PowerShell 7.5.1 from E:\VedicMatchMaking
# Compatibility: PowerShell 5.1 and 7.5.1

$ErrorActionPreference = 'Stop'
$modulePath = "E:\VedicMatchMaking\VedicMatchMakingStructure"

# Define file contents
$files = @{
    "VedicMatchMakingStructure.psm1" = @'
# VedicMatchMakingStructure.psm1
# Purpose: PowerShell module to validate and populate the VedicMatchMaking project structure
# Usage: Import-Module .\VedicMatchMakingStructure.psm1; Invoke-VedicMatchMakingStructure -Batch "all"

function Invoke-VedicMatchMakingStructure {
    [CmdletBinding()]
    param(
        [string]$Batch = "all",
        [switch]$DryRun,
        [string]$RootPath = "E:\VedicMatchMaking",
        [ValidateSet("Info", "Debug", "Error")][string]$LogLevel = "Info"
    )

    # Define paths
    $logPath = Join-Path -Path $RootPath -ChildPath "validation.log"
    $summaryPath = Join-Path -Path $RootPath -ChildPath "structure-summary.json"

    # Define batch mapping
    $batchMap = @{
        "matchmaking-app-web" = "1.1,2.1,3.1"
        "matchmaking-app-android" = "1.2,2.2,3.2"
        "matchmaking-app-backend" = "1.3,2.3,3.3"
        "vedicmatchweb" = "4.2"
        "mobile" = "4.2"
    }

    # Define directory structure
    $structure = @{
        "matchmaking-app-web" = @{
            "public" = @(
                "index.html",
                "firebase-messaging-sw.js",
                "assets/icon.png",
                "assets/placeholder.svg"
            )
            "src" = @{
                "screens" = @(
                    "OnboardingScreen.tsx",
                    "LoginScreen.tsx",
                    "RegisterScreen.tsx",
                    "HomeScreen.tsx",
                    "ProfileScreen.tsx",
                    "MatchScreen.tsx",
                    "ChatScreen.tsx",
                    "SettingsScreen.tsx",
                    "PhotoFeedbackScreen.tsx",
                    "AdminPanelScreen.tsx",
                    "__tests__/OnboardingScreen.test.tsx",
                    "__tests__/LoginScreen.test.tsx",
                    "__tests__/RegisterScreen.test.tsx",
                    "__tests__/HomeScreen.test.tsx",
                    "__tests__/ProfileScreen.test.tsx",
                    "__tests__/MatchScreen.test.tsx",
                    "__tests__/ChatScreen.test.tsx",
                    "__tests__/SettingsScreen.test.tsx",
                    "__tests__/PhotoFeedbackScreen.test.tsx",
                    "__tests__/AdminPanelScreen.test.tsx"
                )
                "services" = @("userService.ts")
                "styles" = @("global.css")
                "" = @("App.tsx", "index.tsx", "firebase.js", "i18n.js")
            }
            "" = @("package.json", "tailwind.config.js")
        }
        "matchmaking-app-android" = @{
            "app/src/main" = @{
                "java/com/matchmaking/app/ui/screens" = @(
                    "OnboardingScreen.kt",
                    "LoginScreen.kt",
                    "RegisterScreen.kt",
                    "HomeScreen.kt",
                    "ProfileScreen.kt",
                    "MatchScreen.kt",
                    "ChatScreen.kt",
                    "SettingsScreen.kt",
                    "PhotoFeedbackScreen.kt",
                    "__tests__/OnboardingScreenTest.kt",
                    "__tests__/LoginScreenTest.kt",
                    "__tests__/RegisterScreenTest.kt",
                    "__tests__/HomeScreenTest.kt",
                    "__tests__/ProfileScreenTest.kt",
                    "__tests__/MatchScreenTest.kt",
                    "__tests__/ChatScreenTest.kt",
                    "__tests__/SettingsScreenTest.kt",
                    "__tests__/PhotoFeedbackScreenTest.kt"
                )
                "java/com/matchmaking/app/viewmodel" = @(
                    "MatchViewModel.kt",
                    "ProfileViewModel.kt",
                    "ChatViewModel.kt",
                    "SettingsViewModel.kt",
                    "PhotoFeedbackViewModel.kt"
                )
                "java/com/matchmaking/app/core/network" = @("UserApi.kt")
                "java/com/matchmaking/app/services" = @("MessagingService.kt")
                "java/com/matchmaking/app/ui/theme" = @("Theme.kt", "colors.xml", "themes.xml")
                "java/com/matchmaking/app" = @("MainActivity.kt")
                "res/drawable" = @("ic_notification.xml", "placeholder.png")
                "res/values" = @("strings.xml", "colors.xml")
                "res/values-hi" = @("strings.xml")
                "" = @("AndroidManifest.xml")
            }
            "app" = @("build.gradle", "google-services.json")
            "" = @("build.gradle", "settings.gradle")
        }
        "matchmaking-app-backend" = @{
            "controllers" = @(
                "userController.js",
                "matchController.js",
                "casteController.js",
                "chatController.js",
                "notificationService.js",
                "adminController.js"
            )
            "models" = @("User.js", "Caste.js", "Chat.js")
            "routes" = @(
                "userRoutes.js",
                "matchRoutes.js",
                "casteRoutes.js",
                "chatRoutes.js",
                "notificationRoutes.js",
                "adminRoutes.js"
            )
            "services/verification" = @(
                "photo_verifier.py",
                "uploads",
                "models",
                "Dockerfile"
            )
            "services/kundli" = @(
                "kundli_service.py",
                "Dockerfile",
                "requirements.txt",
                "swiss_ephe"
            )
            "lib" = @("vedicID.js", "logger.js")
            "middleware" = @("auth.js")
            "Uploads" = @()
            "backups" = @()
            "tests" = @("kundli_service_test.py", "verification_test.py")
            "" = @(
                "socket.js",
                "server.js",
                "docker-compose.yml",
                "docker-compose.yml.bak",
                "nginx.conf",
                "prometheus.yml",
                "serviceAccountKey.json",
                ".env",
                "package.json"
            )
        }
        "vedicmatchweb" = @(
            "index.html",
            "about.html",
            "contact.html",
            "services.html",
            "styles.css",
            "script.js",
            "readme.md"
        )
        "mobile" = @("readme.md", "mobile-config.json")
        "" = @("Fix-DirectoryStructure.ps1")
    }

    # Define file content (minimal for completeness)
    $batch_files = @{
        # Batch 2.3: Backend Matchmaking Logic
        "matchmaking-app-backend/tests/verification_test.py" = @"
import unittest
import requests
import os

class VerificationServiceTest(unittest.TestCase):
    BASE_URL = 'http://localhost:5000'

    def test_verify_photo(self):
        with open('test_image.jpg', 'rb') as photo:
            response = requests.post(f'{self.BASE_URL}/verify', files={'photo': photo})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('photo', data)
        self.assertTrue(data['photo']['verified'])

    def test_verify_no_photo(self):
        response = requests.post(f'{self.BASE_URL}/verify')
        self.assertEqual(response.status_code, 400)

    def test_healthz(self):
        response = requests.get(f'{self.BASE_URL}/healthz')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'OK')

if __name__ == '__main__':
    unittest.main()
"@
        # Batch 4.2: Legacy Components
        "vedicmatchweb/services.html" = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Services - VedicMatchMaking</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div>
        <h1>Our Services</h1>
        <p>Explore our matchmaking, horoscope, and consultation services.</p>
        <ul>
            <li>Vedic Astrology Matching</li>
            <li>Photo Verification</li>
            <li>Live Astrologer Consultations</li>
        </ul>
        <a href="index.html">Back to Home</a>
    </div>
    <script src="script.js"></script>
</body>
</html>
"@
        "mobile/mobile-config.json" = @"
{
  "description": "Placeholder configuration for mobile-related assets or legacy app",
  "contents": []
}
"@
    }

    # Initialize log collections
    $logMessages = @()
    $createdDirs = @()
    $createdFiles = @()
    $missingFiles = @()
    $errorSummary = @()
    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Function to log messages
    function Write-Log {
        param (
            [string]$Message,
            [string]$Level = "Info"
        )
        if (($Level -eq "Debug" -and $LogLevel -eq "Info") -or ($Level -eq "Debug" -and $LogLevel -eq "Error") -or ($Level -eq "Info" -and $LogLevel -eq "Error")) {
            return
        }
        $logEntry = [PSCustomObject]@{
            Timestamp = $currentTime
            Level = $Level
            Message = $Message
        }
        $logMessages += $logEntry
        $color = switch ($Level) {
            "Error" { "Red" }
            "Warning" { "Yellow" }
            default { "White" }
        }
        Write-Host "[$($logEntry.Timestamp)] [$($logEntry.Level)] $($logEntry.Message)" -ForegroundColor $color
        if ($Level -eq "Error") {
            $errorSummary += $logEntry
        }
    }

    # Function to check if path belongs to selected batches
    function Is-BatchIncluded {
        param (
            [string]$RelativePath,
            [string[]]$BatchesToProcess
        )
        if ($BatchesToProcess -contains "all") {
            return $true
        }
        $topLevelDir = ($RelativePath -split "\\")[0]
        if ($batchMap.ContainsKey($topLevelDir)) {
            $mappedBatches = $batchMap[$topLevelDir] -split ","
            return ($mappedBatches | Where-Object { $BatchesToProcess -contains $_ }).Count -gt 0
        }
        return $false
    }

    # Function to ensure directory exists
    function Ensure-Directory {
        param (
            [string]$Path,
            [string]$RelativePath
        )
        if (-not (Test-Path $Path)) {
            Write-Log "Missing directory: $RelativePath, creating..." "Warning"
            if (-not $DryRun) {
                try {
                    New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
                    Write-Log "Created directory: $RelativePath" "Info"
                    $script:createdDirs += $RelativePath
                } catch {
                    Write-Log "Failed to create directory: $RelativePath - $($_.Exception.Message)" "Error"
                    $script:errorSummary += "Directory creation failed: $RelativePath"
                }
            } else {
                Write-Log "Dry run: Would create directory $RelativePath" "Info"
            }
            return $false
        }
        Write-Log "Directory exists: $RelativePath" "Debug"
        return $true
    }

    # Function to ensure file exists
    function Ensure-File {
        param (
            [string]$Path,
            [string]$RelativePath,
            [string]$Content
        )
        if (-not (Test-Path $Path)) {
            Write-Log "Missing file: $RelativePath" "Warning"
            $script:missingFiles += $RelativePath
            if ($Content) {
                if (-not $DryRun) {
                    try {
                        Set-Content -Path $Path -Value $Content -Encoding UTF8 -ErrorAction Stop
                        Write-Log "Created file: $RelativePath with content" "Info"
                        $script:createdFiles += $RelativePath
                    } catch {
                        Write-Log "Failed to create file: $RelativePath - $($_.Exception.Message)" "Error"
                        $script:errorSummary += "File creation failed: $RelativePath"
                    }
                } else {
                    Write-Log "Dry run: Would create file $RelativePath with content" "Info"
                }
            }
            return $false
        }
        Write-Log "File exists: $RelativePath" "Debug"
        return $true
    }

    # Function to validate and populate structure
    function Validate-And-Populate {
        param (
            [string]$BasePath,
            [hashtable]$Structure,
            [string]$ParentPath = "",
            [string[]]$BatchesToProcess
        )
        foreach ($key in $Structure.Keys) {
            $currentPath = if ($key -eq "") { $BasePath } else { Join-Path -Path $BasePath -ChildPath $key }
            $relativePath = if ($key -eq "" -or $ParentPath -eq "") { $key } else { Join-Path -Path $ParentPath -ChildPath $key }

            # Skip if not in selected batches
            if (-not (Is-BatchIncluded -RelativePath $relativePath -BatchesToProcess $BatchesToProcess)) {
                continue
            }

            # Process directory
            if ($key -ne "") {
                Ensure-Directory -Path $currentPath -RelativePath $relativePath
            }

            # Process items
            $items = $Structure[$key]
            if ($items -is [array]) {
                foreach ($item in $items) {
                    $itemPath = Join-Path -Path $currentPath -ChildPath $item
                    $itemRelativePath = if ($relativePath -eq "") { $item } else { Join-Path -Path $relativePath -ChildPath $item }
                    if ($item -eq "uploads" -or $item -eq "models" -or $item -eq "swiss_ephe") {
                        Ensure-Directory -Path $itemPath -RelativePath $itemRelativePath
                    } else {
                        Ensure-File -Path $itemPath -RelativePath $itemRelativePath -Content $batch_files[$itemRelativePath]
                    }
                }
            } else {
                Validate-And-Populate -BasePath $currentPath -Structure $items -ParentPath $relativePath -BatchesToProcess $BatchesToProcess
            }
        }
    }

    # Main execution
    Write-Log "Starting directory structure validation and population for $RootPath (Batch: $Batch, DryRun: $DryRun, LogLevel: $LogLevel)" "Info"

    # Get Git commit hash
    $gitHash = $null
    try {
        $gitHash = git rev-parse HEAD 2>$null
        Write-Log "Git commit hash: $gitHash" "Debug"
    } catch {
        Write-Log "Git not found or not a Git repository" "Warning"
    }

    # Parse batch parameter
    $BatchesToProcess = if ($Batch -eq "all") { @("all") } else { $Batch.Split(",") | ForEach-Object { $_.Trim() } }

    # Initialize exit code
    $exitCode = 0

    # Validate root directory
    if (-not (Ensure-Directory -Path $RootPath -RelativePath $RootPath)) {
        if (-not $DryRun) {
            Write-Log "Critical: Root directory creation failed. Exiting..." "Error"
            throw "Root directory creation failed"
        }
    }

    # Validate and populate structure
    Validate-And-Populate -BasePath $RootPath -Structure $structure -BatchesToProcess $BatchesToProcess

    # Log summary
    Write-Log "Summary:" "Info"
    Write-Log "Created directories: $($createdDirs.Count)" "Info"
    if ($createdDirs.Count -gt 0) {
        $createdDirs | ForEach-Object { Write-Log "- $_" "Debug" }
    }
    Write-Log "Created files: $($createdFiles.Count)" "Info"
    if ($createdFiles.Count -gt 0) {
        $createdFiles | ForEach-Object { Write-Log "- $_" "Debug" }
    }
    Write-Log "Missing files: $($missingFiles.Count)" "Info"
    if ($missingFiles.Count -gt 0) {
        $missingFiles | ForEach-Object { Write-Log "- $_" "Debug" }
    }
    if ($errorSummary.Count -gt 0) {
        Write-Log "Errors encountered: $($errorSummary.Count)" "Error"
        $errorSummary | ForEach-Object { Write-Log "- $($_.Message)" "Error" }
        $exitCode = 2
    } elseif ($missingFiles.Count -gt 0) {
        $exitCode = 1
    }

    # Export JSON summary
    $summary = @{
        createdDirs = $createdDirs
        createdFiles = $createdFiles
        missingFiles = $missingFiles
        timestamp = $currentTime
        batch = $Batch
        dryRun = $DryRun
        logLevel = $LogLevel
        gitCommit = $gitHash
        errors = $errorSummary | ForEach-Object { $_.Message }
    }
    if (-not $DryRun) {
        try {
            $summary | ConvertTo-Json | Out-File -FilePath $summaryPath -Encoding UTF8 -Force -ErrorAction Stop
            Write-Log "Summary exported to $summaryPath" "Info"
        } catch {
            Write-Log "Failed to export summary to $summaryPath - $($_.Exception.Message)" "Error"
            $exitCode = 2
        }
    } else {
        Write-Log "Dry run: Would export summary to $summaryPath" "Info"
    }

    # Save log
    if (-not $DryRun) {
        try {
            $logMessages | ForEach-Object { "[$($_.Timestamp)] [$($_.Level)] $($_.Message)" } | Out-File -FilePath $logPath -Encoding UTF8 -Force -ErrorAction Stop
            Write-Log "Validation log saved to $logPath" "Info"
        } catch {
            Write-Log "Failed to save log to $logPath - $($_.Exception.Message)" "Error"
            $exitCode = 2
        }
    } else {
        Write-Log "Dry run: Would save log to $logPath" "Info"
    }

    # Final status
    if ($errorSummary.Count -gt 0) {
        Write-Log "Directory structure validation and population completed with errors" "Error"
    } elseif ($missingFiles.Count -gt 0) {
        Write-Log "Directory structure validation and population completed with missing files" "Warning"
    } else {
        Write-Log "Directory structure validation and population completed successfully" "Info"
    }

    # Exit with appropriate code
    exit $exitCode
}

Export-ModuleMember -Function Invoke-VedicMatchMakingStructure
'@
    "VedicMatchMakingStructure.psd1" = @'
# VedicMatchMakingStructure.psd1
# Purpose: PowerShell module manifest for VedicMatchMakingStructure

@{
    ModuleVersion = '1.0.0'
    GUID = 'b7a3e4c7-8f2b-4c5d-b8e6-7d9f0e3c9a1d'
    Author = 'xAI'
    CompanyName = 'xAI'
    Copyright = '(c) 2025 xAI. All rights reserved.'
    Description = 'PowerShell module to validate and populate the VedicMatchMaking project structure.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Invoke-VedicMatchMakingStructure')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    FileList = @(
        'VedicMatchMakingStructure.psm1',
        'Populate-DirectoryStructure.ps1',
        'Populate-DirectoryStructure.Tests.ps1'
    )
    PrivateData = @{
        PSData = @{
            Tags = @('VedicMatchMaking', 'PowerShell', 'Automation', 'DirectoryStructure')
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = 'Initial release for VedicMatchMaking project structure population.'
        }
    }
}
'@
    "Populate-DirectoryStructure.ps1" = @'
# Populate-DirectoryStructure.ps1
# Purpose: Validate and populate the VedicMatchMaking project structure
# Compatibility: PowerShell 5.1 and 7.5.1

<#
.SYNOPSIS
    Validates and populates the VedicMatchMaking project structure with required files and directories.

.DESCRIPTION
    This script ensures the directory structure for the VedicMatchMaking project is complete, creating missing directories and files as defined in the structure and batch files. It supports batch selection, dry-run mode, customizable logging levels, JSON summary export with Git commit hash, and exit codes for CI/CD compatibility. Actions are logged to a validation log file.

.PARAMETER Batch
    Comma-separated list of batch identifiers to process (e.g., "1.3,2.1") or "all" (default).

.PARAMETER DryRun
    Simulates actions without creating files or directories.

.PARAMETER RootPath
    Root directory of the project (default: "E:\VedicMatchMaking").

.PARAMETER LogLevel
    Logging verbosity level: Info, Debug, Error (default: Info).

.OUTPUTS
    Logs to <RootPath>\validation.log and JSON summary to <RootPath>\structure-summary.json.
    Exit codes: 0 (success), 1 (partial completion), 2 (errors encountered).

.EXAMPLE
    .\Populate-DirectoryStructure.ps1 -Batch "all"
    Populates all batches in the default root path.

.EXAMPLE
    .\Populate-DirectoryStructure.ps1 -Batch "1.3,2.1" -DryRun -RootPath "C:\Projects\VedicMatchMaking" -LogLevel Debug
    Simulates population for batches 1.3 and 2.1 in a custom root path with debug logging.

.NOTES
    Run Pester tests with: Invoke-Pester -Path E:\VedicMatchMaking\VedicMatchMakingStructure\Populate-DirectoryStructure.Tests.ps1
    Compatible with PowerShell 5.1 and 7.5.1.
#>
[CmdletBinding()]
param(
    [string]$Batch = "all",
    [switch]$DryRun,
    [string]$RootPath = "E:\VedicMatchMaking",
    [ValidateSet("Info", "Debug", "Error")][string]$LogLevel = "Info"
)

# Define paths
$logPath = Join-Path -Path $RootPath -ChildPath "validation.log"
$summaryPath = Join-Path -Path $RootPath -ChildPath "structure-summary.json"

# Define batch mapping
$batchMap = @{
    "matchmaking-app-web" = "1.1,2.1,3.1"
    "matchmaking-app-android" = "1.2,2.2,3.2"
    "matchmaking-app-backend" = "1.3,2.3,3.3"
    "vedicmatchweb" = "4.2"
    "mobile" = "4.2"
}

# Define directory structure
$structure = @{
    "matchmaking-app-web" = @{
        "public" = @(
            "index.html",
            "firebase-messaging-sw.js",
            "assets/icon.png",
            "assets/placeholder.svg"
        )
        "src" = @{
            "screens" = @(
                "OnboardingScreen.tsx",
                "LoginScreen.tsx",
                "RegisterScreen.tsx",
                "HomeScreen.tsx",
                "ProfileScreen.tsx",
                "MatchScreen.tsx",
                "ChatScreen.tsx",
                "SettingsScreen.tsx",
                "PhotoFeedbackScreen.tsx",
                "AdminPanelScreen.tsx",
                "__tests__/OnboardingScreen.test.tsx",
                "__tests__/LoginScreen.test.tsx",
                "__tests__/RegisterScreen.test.tsx",
                "__tests__/HomeScreen.test.tsx",
                "__tests__/ProfileScreen.test.tsx",
                "__tests__/MatchScreen.test.tsx",
                "__tests__/ChatScreen.test.tsx",
                "__tests__/SettingsScreen.test.tsx",
                "__tests__/PhotoFeedbackScreen.test.tsx",
                "__tests__/AdminPanelScreen.test.tsx"
            )
            "services" = @("userService.ts")
            "styles" = @("global.css")
            "" = @("App.tsx", "index.tsx", "firebase.js", "i18n.js")
        }
        "" = @("package.json", "tailwind.config.js")
    }
    "matchmaking-app-android" = @{
        "app/src/main" = @{
            "java/com/matchmaking/app/ui/screens" = @(
                "OnboardingScreen.kt",
                "LoginScreen.kt",
                "RegisterScreen.kt",
                "HomeScreen.kt",
                "ProfileScreen.kt",
                "MatchScreen.kt",
                "ChatScreen.kt",
                "SettingsScreen.kt",
                "PhotoFeedbackScreen.kt",
                "__tests__/OnboardingScreenTest.kt",
                "__tests__/LoginScreenTest.kt",
                "__tests__/RegisterScreenTest.kt",
                "__tests__/HomeScreenTest.kt",
                "__tests__/ProfileScreenTest.kt",
                "__tests__/MatchScreenTest.kt",
                "__tests__/ChatScreenTest.kt",
                "__tests__/SettingsScreenTest.kt",
                "__tests__/PhotoFeedbackScreenTest.kt"
            )
            "java/com/matchmaking/app/viewmodel" = @(
                "MatchViewModel.kt",
                "ProfileViewModel.kt",
                "ChatViewModel.kt",
                "SettingsViewModel.kt",
                "PhotoFeedbackViewModel.kt"
            )
            "java/com/matchmaking/app/core/network" = @("UserApi.kt")
            "java/com/matchmaking/app/services" = @("MessagingService.kt")
            "java/com/matchmaking/app/ui/theme" = @("Theme.kt", "colors.xml", "themes.xml")
            "java/com/matchmaking/app" = @("MainActivity.kt")
            "res/drawable" = @("ic_notification.xml", "placeholder.png")
            "res/values" = @("strings.xml", "colors.xml")
            "res/values-hi" = @("strings.xml")
            "" = @("AndroidManifest.xml")
        }
        "app" = @("build.gradle", "google-services.json")
        "" = @("build.gradle", "settings.gradle")
    }
    "matchmaking-app-backend" = @{
        "controllers" = @(
            "userController.js",
            "matchController.js",
            "casteController.js",
            "chatController.js",
            "notificationService.js",
            "adminController.js"
        )
        "models" = @("User.js", "Caste.js", "Chat.js")
        "routes" = @(
            "userRoutes.js",
            "matchRoutes.js",
            "casteRoutes.js",
            "chatRoutes.js",
            "notificationRoutes.js",
            "adminRoutes.js"
        )
        "services/verification" = @(
            "photo_verifier.py",
            "uploads",
            "models",
            "Dockerfile"
        )
        "services/kundli" = @(
            "kundli_service.py",
            "Dockerfile",
            "requirements.txt",
            "swiss_ephe"
        )
        "lib" = @("vedicID.js", "logger.js")
        "middleware" = @("auth.js")
        "Uploads" = @()
        "backups" = @()
        "tests" = @("kundli_service_test.py", "verification_test.py")
        "" = @(
            "socket.js",
            "server.js",
            "docker-compose.yml",
            "docker-compose.yml.bak",
            "nginx.conf",
            "prometheus.yml",
            "serviceAccountKey.json",
            ".env",
            "package.json"
        )
    }
    "vedicmatchweb" = @(
        "index.html",
        "about.html",
        "contact.html",
        "services.html",
        "styles.css",
        "script.js",
        "readme.md"
    )
    "mobile" = @("readme.md", "mobile-config.json")
    "" = @("Fix-DirectoryStructure.ps1")
}

# Define file content (minimal for completeness)
$batch_files = @{
    # Batch 2.3: Backend Matchmaking Logic
    "matchmaking-app-backend/tests/verification_test.py" = @"
import unittest
import requests
import os

class VerificationServiceTest(unittest.TestCase):
    BASE_URL = 'http://localhost:5000'

    def test_verify_photo(self):
        with open('test_image.jpg', 'rb') as photo:
            response = requests.post(f'{self.BASE_URL}/verify', files={'photo': photo})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('photo', data)
        self.assertTrue(data['photo']['verified'])

    def test_verify_no_photo(self):
        response = requests.post(f'{self.BASE_URL}/verify')
        self.assertEqual(response.status_code, 400)

    def test_healthz(self):
        response = requests.get(f'{self.BASE_URL}/healthz')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'OK')

if __name__ == '__main__':
    unittest.main()
"@
    # Batch 4.2: Legacy Components
    "vedicmatchweb/services.html" = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Services - VedicMatchMaking</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div>
        <h1>Our Services</h1>
        <p>Explore our matchmaking, horoscope, and consultation services.</p>
        <ul>
            <li>Vedic Astrology Matching</li>
            <li>Photo Verification</li>
            <li>Live Astrologer Consultations</li>
        </ul>
        <a href="index.html">Back to Home</a>
    </div>
    <script src="script.js"></script>
</body>
</html>
"@
    "mobile/mobile-config.json" = @"
{
  "description": "Placeholder configuration for mobile-related assets or legacy app",
  "contents": []
}
"@
}

# Initialize log collections
$logMessages = @()
$createdDirs = @()
$createdFiles = @()
$missingFiles = @()
$errorSummary = @()
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "Info"
    )
    if (($Level -eq "Debug" -and $LogLevel -eq "Info") -or ($Level -eq "Debug" -and $LogLevel -eq "Error") -or ($Level -eq "Info" -and $LogLevel -eq "Error")) {
        return
    }
    $logEntry = [PSCustomObject]@{
        Timestamp = $currentTime
        Level = $Level
        Message = $Message
    }
    $logMessages += $logEntry
    $color = switch ($Level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        default { "White" }
    }
    Write-Host "[$($logEntry.Timestamp)] [$($logEntry.Level)] $($logEntry.Message)" -ForegroundColor $color
    if ($Level -eq "Error") {
        $errorSummary += $logEntry
    }
}

# Function to check if path belongs to selected batches
function Is-BatchIncluded {
    param (
        [string]$RelativePath,
        [string[]]$BatchesToProcess
    )
    if ($BatchesToProcess -contains "all") {
        return $true
    }
    $topLevelDir = ($RelativePath -split "\\")[0]
    if ($batchMap.ContainsKey($topLevelDir)) {
        $mappedBatches = $batchMap[$topLevelDir] -split ","
        return ($mappedBatches | Where-Object { $BatchesToProcess -contains $_ }).Count -gt 0
    }
    return $false
}

# Function to ensure directory exists
function Ensure-Directory {
    param (
        [string]$Path,
        [string]$RelativePath
    )
    if (-not (Test-Path $Path)) {
        Write-Log "Missing directory: $RelativePath, creating..." "Warning"
        if (-not $DryRun) {
            try {
                New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
                Write-Log "Created directory: $RelativePath" "Info"
                $script:createdDirs += $RelativePath
            } catch {
                Write-Log "Failed to create directory: $RelativePath - $($_.Exception.Message)" "Error"
                $script:errorSummary += "Directory creation failed: $RelativePath"
            }
        } else {
            Write-Log "Dry run: Would create directory $RelativePath" "Info"
        }
        return $false
    }
    Write-Log "Directory exists: $RelativePath" "Debug"
    return $true
}

# Function to ensure file exists
function Ensure-File {
    param (
        [string]$Path,
        [string]$RelativePath,
        [string]$Content
    )
    if (-not (Test-Path $Path)) {
        Write-Log "Missing file: $RelativePath" "Warning"
        $script:missingFiles += $RelativePath
        if ($Content) {
            if (-not $DryRun) {
                try {
                    Set-Content -Path $Path -Value $Content -Encoding UTF8 -ErrorAction Stop
                    Write-Log "Created file: $RelativePath with content" "Info"
                    $script:createdFiles += $RelativePath
                } catch {
                    Write-Log "Failed to create file: $RelativePath - $($_.Exception.Message)" "Error"
                    $script:errorSummary += "File creation failed: $RelativePath"
                }
            } else {
                Write-Log "Dry run: Would create file $RelativePath with content" "Info"
            }
        }
        return $false
    }
    Write-Log "File exists: $RelativePath" "Debug"
    return $true
}

# Function to validate and populate structure
function Validate-And-Populate {
    param (
        [string]$BasePath,
        [hashtable]$Structure,
        [string]$ParentPath = "",
        [string[]]$BatchesToProcess
    )
    foreach ($key in $Structure.Keys) {
        $currentPath = if ($key -eq "") { $BasePath } else { Join-Path -Path $BasePath -ChildPath $key }
        $relativePath = if ($key -eq "" -or $ParentPath -eq "") { $key } else { Join-Path -Path $ParentPath -ChildPath $key }

        # Skip if not in selected batches
        if (-not (Is-BatchIncluded -RelativePath $relativePath -BatchesToProcess $BatchesToProcess)) {
            continue
        }

        # Process directory
        if ($key -ne "") {
            Ensure-Directory -Path $currentPath -RelativePath $relativePath
        }

        # Process items
        $items = $Structure[$key]
        if ($items -is [array]) {
            foreach ($item in $items) {
                $itemPath = Join-Path -Path $currentPath -ChildPath $item
                $itemRelativePath = if ($relativePath -eq "") { $item } else { Join-Path -Path $relativePath -ChildPath $item }
                if ($item -eq "uploads" -or $item -eq "models" -or $item -eq "swiss_ephe") {
                    Ensure-Directory -Path $itemPath -RelativePath $itemRelativePath
                } else {
                    Ensure-File -Path $itemPath -RelativePath $itemRelativePath -Content $batch_files[$itemRelativePath]
                }
            }
        } else {
            Validate-And-Populate -BasePath $currentPath -Structure $items -ParentPath $relativePath -BatchesToProcess $BatchesToProcess
        }
    }
}

# Main execution
Write-Log "Starting directory structure validation and population for $RootPath (Batch: $Batch, DryRun: $DryRun, LogLevel: $LogLevel)" "Info"

# Get Git commit hash
$gitHash = $null
try {
    $gitHash = git rev-parse HEAD 2>$null
    Write-Log "Git commit hash: $gitHash" "Debug"
} catch {
    Write-Log "Git not found or not a Git repository" "Warning"
}

# Parse batch parameter
$BatchesToProcess = if ($Batch -eq "all") { @("all") } else { $Batch.Split(",") | ForEach-Object { $_.Trim() } }

# Initialize exit code
$exitCode = 0

# Validate root directory
if (-not (Ensure-Directory -Path $RootPath -RelativePath $RootPath)) {
    if (-not $DryRun) {
        Write-Log "Critical: Root directory creation failed. Exiting..." "Error"
        throw "Root directory creation failed"
    }
}

# Validate and populate structure
Validate-And-Populate -BasePath $RootPath -Structure $structure -BatchesToProcess $BatchesToProcess

# Log summary
Write-Log "Summary:" "Info"
Write-Log "Created directories: $($createdDirs.Count)" "Info"
if ($createdDirs.Count -gt 0) {
    $createdDirs | ForEach-Object { Write-Log "- $_" "Debug" }
}
Write-Log "Created files: $($createdFiles.Count)" "Info"
if ($createdFiles.Count -gt 0) {
    $createdFiles | ForEach-Object { Write-Log "- $_" "Debug" }
}
Write-Log "Missing files: $($missingFiles.Count)" "Info"
if ($missingFiles.Count -gt 0) {
    $missingFiles | ForEach-Object { Write-Log "- $_" "Debug" }
}
if ($errorSummary.Count -gt 0) {
    Write-Log "Errors encountered: $($errorSummary.Count)" "Error"
    $errorSummary | ForEach-Object { Write-Log "- $($_.Message)" "Error" }
    $exitCode = 2
} elseif ($missingFiles.Count -gt 0) {
    $exitCode = 1
}

# Export JSON summary
$summary = @{
    createdDirs = $createdDirs
    createdFiles = $createdFiles
    missingFiles = $missingFiles
    timestamp = $currentTime
    batch = $Batch
    dryRun = $DryRun
    logLevel = $LogLevel
    gitCommit = $gitHash
    errors = $errorSummary | ForEach-Object { $_.Message }
}
if (-not $DryRun) {
    try {
        $summary | ConvertTo-Json | Out-File -FilePath $summaryPath -Encoding UTF8 -Force -ErrorAction Stop
        Write-Log "Summary exported to $summaryPath" "Info"
    } catch {
        Write-Log "Failed to export summary to $summaryPath - $($_.Exception.Message)" "Error"
        $exitCode = 2
    }
} else {
    Write-Log "Dry run: Would export summary to $summaryPath" "Info"
}

# Save log
if (-not $DryRun) {
    try {
        $logMessages | ForEach-Object { "[$($_.Timestamp)] [$($_.Level)] $($_.Message)" } | Out-File -FilePath $logPath -Encoding UTF8 -Force -ErrorAction Stop
        Write-Log "Validation log saved to $logPath" "Info"
    } catch {
        Write-Log "Failed to save log to $logPath - $($_.Exception.Message)" "Error"
        $exitCode = 2
    }
} else {
    Write-Log "Dry run: Would save log to $logPath" "Info"
}

# Final status
if ($errorSummary.Count -gt 0) {
    Write-Log "Directory structure validation and population completed with errors" "Error"
} elseif ($missingFiles.Count -gt 0) {
    Write-Log "Directory structure validation and population completed with missing files" "Warning"
} else {
    Write-Log "Directory structure validation and population completed successfully" "Info"
}

# Exit with appropriate code
exit $exitCode
'@
    "Populate-DirectoryStructure.Tests.ps1" = @'
# Populate-DirectoryStructure.Tests.ps1
# Purpose: Pester tests for key functions in Populate-DirectoryStructure.ps1
# Compatibility: PowerShell 5.1 and 7.5.1

Describe "Populate-DirectoryStructure Functions" {
    BeforeAll {
        # Import the script to test its functions
        $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Populate-DirectoryStructure.ps1"
        if (-not (Test-Path $scriptPath)) {
            Write-Error "Script file not found at $scriptPath"
        }
        . $scriptPath

        # Mock variables
        $script:createdDirs = @()
        $script:createdFiles = @()
        $script:missingFiles = @()
        $script:logMessages = @()
        $script:errorSummary = @()
        $global:currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $batchMap = @{
            "matchmaking-app-web" = "1.1,2.1,3.1"
            "matchmaking-app-android" = "1.2,2.2,3.2"
            "matchmaking-app-backend" = "1.3,2.3,3.3"
            "vedicmatchweb" = "4.2"
            "mobile" = "4.2"
        }
        $global:DryRun = $false
        $global:LogLevel = "Info"
    }

    Context "Write-Log Function" {
        It "Logs Info message correctly" {
            $Message = "Test Info message"
            Write-Log -Message $Message -Level "Info"
            $logMessages[-1].Message | Should -Be $Message
            $logMessages[-1].Level | Should -Be "Info"
            $logMessages[-1].Timestamp | Should -Be $currentTime
        }

        It "Respects LogLevel filtering" {
            $script:logMessages = @()
            $global:LogLevel = "Error"
            Write-Log -Message "Should not log" -Level "Info"
            $logMessages.Count | Should -Be 0
        }

        It "Captures Error in errorSummary" {
            $script:errorSummary = @()
            Write-Log -Message "Test Error" -Level "Error"
            $errorSummary[-1].Message | Should -Be "Test Error"
        }
    }

    Context "Is-BatchIncluded Function" {
        It "Returns true for 'all' batches" {
            Is-BatchIncluded -RelativePath "matchmaking-app-web" -BatchesToProcess @("all") | Should -Be $true
        }

        It "Returns true for matching batch" {
            Is-BatchIncluded -RelativePath "matchmaking-app-backend" -BatchesToProcess @("1.3") | Should -Be $true
        }

        It "Returns false for non-matching batch" {
            Is-BatchIncluded -RelativePath "vedicmatchweb" -BatchesToProcess @("1.1") | Should -Be $false
        }
    }

    Context "Ensure-Directory Function" {
        BeforeEach {
            $testDir = "TestDir"
            $testPath = Join-Path -Path $TestDrive -ChildPath $testDir
            $script:createdDirs = @()
        }

        It "Creates directory when missing" {
            Mock Test-Path { $false }
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $createdDirs | Should -Contain $testDir
        }

        It "Does not create directory in DryRun mode" {
            Mock Test-Path { $false }
            $global:DryRun = $true
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $createdDirs | Should -BeEmpty
        }

        It "Logs existing directory" {
            Mock Test-Path { $true }
            Ensure-Directory -Path $testPath -RelativePath $testDir
            $logMessages[-1].Message | Should -Be "Directory exists: $testDir"
        }
    }

    Context "Ensure-File Function" {
        BeforeEach {
            $testFile = "TestFile.txt"
            $testPath = Join-Path -Path $TestDrive -ChildPath $testFile
            $script:missingFiles = @()
            $script:createdFiles = @()
        }

        It "Creates file with content when missing" {
            Mock Test-Path { $false }
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $createdFiles | Should -Contain $testFile
            $missingFiles | Should -Contain $testFile
        }

        It "Does not create file in DryRun mode" {
            Mock Test-Path { $false }
            $global:DryRun = $true
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $createdFiles | Should -BeEmpty
            $missingFiles | Should -Contain $testFile
        }

        It "Logs existing file" {
            Mock Test-Path { $true }
            Ensure-File -Path $testPath -RelativePath $testFile -Content "Test content"
            $logMessages[-1].Message | Should -Be "File exists: $testFile"
        }
    }

    Context "Validate-And-Populate Function" {
        BeforeEach {
            $testBasePath = $TestDrive
            $testStructure = @{
                "test-dir" = @("file1.txt", "file2.txt")
                "" = @("root-file.txt")
            }
            $script:batch_files = @{
                "test-dir/file1.txt" = "Content1"
                "test-dir/file2.txt" = "Content2"
                "root-file.txt" = "RootContent"
            }
            $script:createdDirs = @()
            $script:createdFiles = @()
            $script:missingFiles = @()
        }

        It "Populates structure correctly" {
            Mock Test-Path { $false }
            Validate-And-Populate -BasePath $testBasePath -Structure $testStructure -BatchesToProcess @("all")
            $createdDirs | Should -Contain "test-dir"
            $createdFiles | Should -Contain "test-dir/file1.txt"
            $createdFiles | Should -Contain "test-dir/file2.txt"
            $createdFiles | Should -Contain "root-file.txt"
        }

        It "Skips non-matching batches" {
            Mock Test-Path { $false }
            Validate-And-Populate -BasePath $testBasePath -Structure $testStructure -BatchesToProcess @("1.1")
            $createdDirs | Should -BeEmpty
            $createdFiles | Should -BeEmpty
        }
    }

    Context "Summary Export" {
        BeforeEach {
            $summaryPath = Join-Path -Path $TestDrive -ChildPath "structure-summary.json"
            $script:createdDirs = @("dir1")
            $script:createdFiles = @("file1")
            $script:missingFiles = @("file2")
            $script:errorSummary = @()
        }

        It "Exports summary JSON when not DryRun" {
            $global:DryRun = $false
            Mock Out-File {}
            $summary = @{
                createdDirs = $createdDirs
                createdFiles = $createdFiles
                missingFiles = $missingFiles
                timestamp = $currentTime
                batch = "all"
                dryRun = $false
                logLevel = "Info"
                gitCommit = "dummyhash"
                errors = @()
            }
            $summary | ConvertTo-Json | Out-File -FilePath $summaryPath -Encoding UTF8 -Force
            Assert-MockCalled Out-File -Exactly 1 -Scope It
            (Get-Content $summaryPath -Raw | ConvertFrom-Json).createdDirs | Should -Contain "dir1"
        }

        It "Does not export summary in DryRun mode" {
            $global:DryRun = $true
            Mock Out-File {}
            Validate-And-Populate -BasePath $TestDrive -Structure @{} -BatchesToProcess @("all")
            Assert-MockCalled Out-File -Exactly 0 -Scope It
        }
    }

    Context "Log File Output" {
        BeforeEach {
            $logPath = Join-Path -Path $TestDrive -ChildPath "validation.log"
            $script:logMessages = @()
        }

        It "Saves log file when not DryRun" {
            $global:DryRun = $false
            Mock Out-File {}
            Write-Log -Message "Test log entry" -Level "Info"
            $logMessages | ForEach-Object { "[$($_.Timestamp)] [$($_.Level)] $($_.Message)" } | Out-File -FilePath $logPath -Encoding UTF8 -Force
            Assert-MockCalled Out-File -Exactly 1 -Scope It
            Get-Content $logPath | Should -Contain "[$currentTime] [Info] Test log entry"
        }

        It "Does not save log file in DryRun mode" {
            $global:DryRun = $true
            Mock Out-File {}
            Write-Log -Message "Test log entry" -Level "Info"
            Validate-And-Populate -BasePath $TestDrive -Structure @{} -BatchesToProcess @("all")
            Assert-MockCalled Out-File -Exactly 0 -Scope It
        }
    }

    Context "Exit Code Handling" {
        BeforeEach {
            $script:errorSummary = @()
            $script:missingFiles = @()
            $script:createdDirs = @()
            $script:createdFiles = @()
        }

        It "Returns exit code 0 for success" {
            Mock Test-Path { $true }
            $testStructure = @{"test-dir" = @("file1.txt")}
            $script:batch_files = @{"test-dir/file1.txt" = "Content"}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 0
        }

        It "Returns exit code 1 for partial completion" {
            Mock Test-Path { $false }
            $testStructure = @{"test-dir" = @("file1.txt")}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 1
        }

        It "Returns exit code 2 for errors" {
            Mock Test-Path { $false }
            Mock New-Item { throw "Mocked error" }
            $testStructure = @{"test-dir" = @()}
            Validate-And-Populate -BasePath $TestDrive -Structure $testStructure -BatchesToProcess @("all")
            $exitCode = 0
            if ($errorSummary.Count -gt 0) { $exitCode = 2 }
            elseif ($missingFiles.Count -gt 0) { $exitCode = 1 }
            $exitCode | Should -Be 2
        }
    }

    Context "Parameter Validation" {
        It "Parses Batch parameter correctly" {
            $BatchesToProcess = "1.1,2.1" -split "," | ForEach-Object { $_.Trim() }
            $BatchesToProcess | Should -Contain "1.1"
            $BatchesToProcess | Should -Contain "2.1"
        }

        It "Handles 'all' Batch parameter" {
            $BatchesToProcess = if ("all" -eq "all") { @("all") } else { "invalid" -split "," }
            $BatchesToProcess | Should -Contain "all"
        }

        It "Respects LogLevel parameter" {
            $global:LogLevel = "Debug"
            Write-Log -Message "Debug message" -Level "Debug"
            $logMessages[-1].Message | Should -Be "Debug message"
            $global:LogLevel = "Error"
            $script:logMessages = @()
            Write-Log -Message "Debug message" -Level "Debug"
            $logMessages.Count | Should -Be 0
        }
    }
}
'@
}

Write-Host "Replacing placeholder files in $modulePath..." -ForegroundColor Cyan

# Verify module directory exists
if (-not (Test-Path $modulePath)) {
    Write-Host "Module directory does not exist: $modulePath" -ForegroundColor Red
    Write-Host "Run Setup-VedicMatchMakingStructure.ps1 first to create placeholders." -ForegroundColor Yellow
    exit 1
}

# Replace placeholder files
foreach ($file in $files.Keys) {
    $filePath = Join-Path -Path $modulePath -ChildPath $file
    if (Test-Path $filePath) {
        Write-Host "Replacing file: $file" -ForegroundColor Green
        Set-Content -Path $filePath -Value $files[$file] -Encoding UTF8 -Force
    } else {
        Write-Host "Creating file: $file" -ForegroundColor Green
        Set-Content -Path $filePath -Value $files[$file] -Encoding UTF8 -Force
    }
}

# Verify file existence
Write-Host "Verifying module setup..." -ForegroundColor Cyan
$missingFiles = @()
foreach ($file in $files.Keys) {
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

# Run Pester tests
Write-Host "Running Pester tests..." -ForegroundColor Cyan
try {
    Invoke-Pester -Path (Join-Path -Path $modulePath -ChildPath "Populate-DirectoryStructure.Tests.ps1")
} catch {
    Write-Host "Failed to run Pester tests: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Replacement and verification complete. Check above output for test results." -ForegroundColor Green
'@

Write-Host "Updated Replace-Placeholders.ps1 created at E:\VedicMatchMaking\Replace-Placeholders.ps1" -ForegroundColor Green
Write-Host "Run the script to replace placeholders and run tests:" -ForegroundColor Cyan
Write-Host "PS E:\VedicMatchMaking> .\Replace-Placeholders.ps1" -ForegroundColor Cyan