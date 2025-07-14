<#
.SYNOPSIS
  Safely injects Android signingConfig block into build.gradle (Groovy DSL).

.DESCRIPTION
  - Reads build.gradle line by line
  - Finds release { block
  - Inserts signingConfig signingConfigs.release if missing
  - Creates a .bak backup before writing

.PARAMETER FilePath
  Path to build.gradle file (default: .\app\build.gradle)
#>

param (
  [string]$FilePath = ".\app\build.gradle"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Android SigningConfig Injector for build.gradle (Safe Mode)"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $FilePath)) {
    Write-Error "❌ ERROR: File not found at $FilePath"
    exit 1
}

# 1️⃣ Make a backup
$backupPath = "$FilePath.bak"
Copy-Item $FilePath $backupPath -Force
Write-Host "✅ Backup created at $backupPath"

# 2️⃣ Read file
$lines = Get-Content $FilePath
$newLines = @()
$insideReleaseBlock = $false
$alreadyHasSigningConfig = $false

foreach ($line in $lines) {
    $trimmed = $line.Trim()

    # Detect start of release block
    if ($trimmed -match '^\s*release\s*{') {
        $insideReleaseBlock = $true
    }

    # Check if signingConfig line exists
    if ($insideReleaseBlock -and $trimmed -match 'signingConfig\s+signingConfigs\.release') {
        $alreadyHasSigningConfig = $true
    }

    $newLines += $line

    # Inject after release {
    if ($insideReleaseBlock -and -not $alreadyHasSigningConfig -and $trimmed -match '^\s*release\s*{') {
        # Determine indent
        $indent = ($line -replace 'release\s*{.*$','')
        $newLines += "$indent    signingConfig signingConfigs.release"
        $alreadyHasSigningConfig = $true
        Write-Host "✅ Injected signingConfig reference in release buildType"
    }

    # Detect end of release block
    if ($insideReleaseBlock -and $trimmed -eq '}') {
        $insideReleaseBlock = $false
    }
}

if ($alreadyHasSigningConfig) {
    Write-Host "✅ signingConfig is present. No duplicates will be added."
} else {
    Write-Host "⚠️ No release block found, or could not inject signingConfig."
}

# 3️⃣ Write updated lines
$newLines | Set-Content $FilePath -Encoding UTF8
Write-Host "✅ build.gradle updated at $FilePath"
Write-Host "------------------------------------------------------------"
