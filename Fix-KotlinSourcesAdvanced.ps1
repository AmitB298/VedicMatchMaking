<#
.SYNOPSIS
Advanced Kotlin Source Cleaner and Fixer for Android Projects.

.DESCRIPTION
- Ensures valid package declaration.
- Moves all imports to the top of the file.
- Deduplicates imports.
- Removes misplaced imports inside classes/functions.
- Adds ExperimentalMaterial3Api import if needed.
- Inserts @OptIn annotations above Composables or Activities.
- Can inject a default package if missing.

.PARAMETER SourceRoot
Root folder containing Kotlin files.

.PARAMETER DefaultPackage
(Optional) Default package name to insert if missing.

.EXAMPLE
.\Fix-KotlinSourcesAdvanced.ps1 -SourceRoot ".\app\src\main\java" -DefaultPackage "com.matchmaking.app"
#>

param(
    [Parameter(Mandatory)]
    [string]$SourceRoot,

    [string]$DefaultPackage
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Advanced Kotlin Source Cleaner & Fixer"
Write-Host "------------------------------------------------------------"

$ktFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter *.kt

foreach ($file in $ktFiles) {
    $lines = Get-Content $file.FullName
    $packageLine = $null
    $imports = @()
    $codeLines = @()
    $seenImports = @{}
    $needsExperimentalOptIn = $false
    $experimentalImport = 'import androidx.compose.material3.ExperimentalMaterial3Api'

    # 1️⃣ First pass: separate package, imports, and code
    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        if ($trimmed -match '^package\s+') {
            $packageLine = $trimmed
        }
        elseif ($trimmed -match '^import\s+') {
            if (-not $seenImports.ContainsKey($trimmed)) {
                $imports += $trimmed
                $seenImports[$trimmed] = $true
            }
        }
        else {
            # Collect any @OptIn markers to avoid duplicate injection
            if ($trimmed -match '@OptIn\(ExperimentalMaterial3Api::class\)') {
                $needsExperimentalOptIn = $true
            }
            $codeLines += $line
        }
    }

    # 2️⃣ Handle missing package
    if (-not $packageLine) {
        if ($DefaultPackage) {
            $packageLine = "package $DefaultPackage"
            Write-Host "✅ Inserted default package in: $($file.FullName)"
        } else {
            Write-Warning "⚠️ No package line in: $($file.FullName) (no default provided)"
        }
    }

    # 3️⃣ Add ExperimentalMaterial3Api import if needed later
    $finalCodeLines = @()
    for ($i = 0; $i -lt $codeLines.Count; $i++) {
        $currentLine = $codeLines[$i]

        if ($currentLine -match '(@Composable|fun .*Composable|class .*Activity)') {
            $prev = if ($i -gt 0) { $codeLines[$i - 1].Trim() } else { "" }
            if ($prev -notmatch '@OptIn\(ExperimentalMaterial3Api::class\)') {
                $finalCodeLines += '    @OptIn(ExperimentalMaterial3Api::class)'
                $needsExperimentalOptIn = $true
            }
        }

        $finalCodeLines += $currentLine
    }

    if ($needsExperimentalOptIn -and -not ($imports -contains $experimentalImport)) {
        $imports += $experimentalImport
    }

    # 4️⃣ Deduplicate and sort imports
    $imports = $imports | Sort-Object -Unique

    # 5️⃣ Build new file content
    $newContent = @()
    if ($packageLine) {
        $newContent += $packageLine
        $newContent += ""
    }

    if ($imports.Count -gt 0) {
        $newContent += $imports
        $newContent += ""
    }

    $newContent += $finalCodeLines

    # 6️⃣ Write back
    Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8

    Write-Host "✅ Fixed: $($file.FullName)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 ALL DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
