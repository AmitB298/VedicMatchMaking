param(
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Advanced Kotlin Source Cleaner & Restructurer"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $SourceRoot)) {
    Write-Error "❌ ERROR: Source root not found at path: $SourceRoot"
    exit 1
}

$ktFiles = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt

if (-Not $ktFiles) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $ktFiles) {
    $lines = Get-Content $file.FullName -Raw -Encoding UTF8 -ErrorAction Stop
    $linesArray = $lines -split "`r?`n"

    # Identify package
    $packageLine = $linesArray | Where-Object { $_ -match "^package\s+" } | Select-Object -First 1

    if (-Not $packageLine) {
        Write-Warning "⚠️ No package line in: $($file.FullName)"
        $packageLine = ""
    }

    # Collect imports
    $importLines = $linesArray | Where-Object { $_ -match "^import\s+" }
    $importLines = $importLines | Sort-Object -Unique

    # Detect other code lines (non-blank, non-import, non-package)
    $codeLines = $linesArray | Where-Object { ($_ -notmatch "^package\s+") -and ($_ -notmatch "^import\s+") }

    # Ensure imports appear *only once*
    $cleanBody = @()
    $inImports = $false
    foreach ($line in $codeLines) {
        if ($line -match "^import\s+") {
            continue
        }
        if ($line.Trim() -eq "") {
            continue
        }
        $cleanBody += $line
    }

    # Check if we need ExperimentalMaterial3Api OptIn
    $usesMaterial3 = $cleanBody | Where-Object { $_ -match "(Scaffold|MaterialTheme|LargeTopAppBar|SmallTopAppBar)" }
    $hasOptIn = $cleanBody | Where-Object { $_ -match "ExperimentalMaterial3Api" }

    if ($usesMaterial3 -and -not $hasOptIn) {
        # Add OptIn above @Composable functions
        $cleanBody = $cleanBody | ForEach-Object {
            if ($_ -match "(@Composable\s+fun\s+)") {
                "@OptIn(ExperimentalMaterial3Api::class)"
                $_
            } else {
                $_
            }
        }
        if ($importLines -notcontains "import androidx.compose.material3.ExperimentalMaterial3Api") {
            $importLines += "import androidx.compose.material3.ExperimentalMaterial3Api"
        }
    }

    # Compose final content
    $newContent = @()
    if ($packageLine -ne "") {
        $newContent += $packageLine
    }
    $newContent += ""
    $newContent += ($importLines | Sort-Object -Unique)
    $newContent += ""
    $newContent += $cleanBody

    # Write back
    Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
    Write-Host "✅ Fixed: $($file.FullName)"
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 ALL DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
