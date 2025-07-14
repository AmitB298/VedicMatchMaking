<#
.SYNOPSIS
    Ensures keystore.properties storeFile entry is correct.

.DESCRIPTION
    Removes any incorrect path prefixes (like 'app/') from storeFile.
    Confirms the .jks exists in the app/ folder.
    Updates keystore.properties if needed.

.PARAMETER RootPath
    Root path of your project (where keystore.properties is found).

.EXAMPLE
    .\Fix-KeystoreProperties.ps1 -RootPath "E:\VedicCouple\matchmaking-app-android"
#>

param(
    [string]$RootPath = "."
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Android Keystore.properties Auto-Fixer"
Write-Host "------------------------------------------------------------"

$keystoreFile = Join-Path $RootPath "keystore.properties"

if (-not (Test-Path $keystoreFile)) {
    Write-Error "❌ keystore.properties not found at: $keystoreFile"
    exit 1
}

# Load lines
$lines = Get-Content $keystoreFile -Encoding UTF8

# Check for storeFile
$fixedLines = @()
$storeFileFixed = $false
foreach ($line in $lines) {
    if ($line -match '^\s*storeFile\s*=') {
        $parts = $line -split '='
        $value = $parts[1].Trim()

        # Strip any folder prefix
        $fileName = Split-Path $value -Leaf

        # Check if corrected
        if ($fileName -ne $value) {
            Write-Host "⚠️  Found prefixed storeFile path: '$value'"
            Write-Host "✅ Correcting to just filename: '$fileName'"
            $storeFileFixed = $true
        } else {
            Write-Host "✅ storeFile already correct: '$fileName'"
        }

        # Rebuild line
        $fixedLines += "storeFile=$fileName"
    } else {
        $fixedLines += $line
    }
}

# Overwrite if changed
if ($storeFileFixed) {
    Write-Host "✅ Writing corrected keystore.properties..."
    $backup = $keystoreFile + ".bak"
    Copy-Item $keystoreFile $backup -Force
    $fixedLines | Set-Content $keystoreFile -Encoding UTF8
    Write-Host "✅ Backup created at: $backup"
} else {
    Write-Host "✅ No changes needed."
}

# Check that .jks file actually exists in app folder
$appPath = Join-Path $RootPath "app"
$storeFileEntry = ($fixedLines | Where-Object { $_ -match '^\s*storeFile\s*=' }) -replace '^\s*storeFile\s*=\s*',''
$jksFile = Join-Path $appPath $storeFileEntry

if (Test-Path $jksFile) {
    Write-Host "✅ Keystore file exists at: $jksFile"
} else {
    Write-Warning "⚠️  Keystore file NOT found at expected location:"
    Write-Warning "   $jksFile"
    Write-Warning "⚠️  Please make sure your .jks file is in the app folder!"
}

Write-Host "------------------------------------------------------------"
Write-Host "✅ keystore.properties validation complete"
Write-Host "------------------------------------------------------------"
