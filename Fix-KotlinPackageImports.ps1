param (
    [string]$SourceRoot = ".\app\src\main\java"
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kotlin Package & Import Fixer"
Write-Host "------------------------------------------------------------"

if (-Not (Test-Path $SourceRoot)) {
    Write-Error "❌ ERROR: Source root not found at path: $SourceRoot"
    exit 1
}

$files = Get-ChildItem -Path $SourceRoot -Recurse -Include *.kt

if (-Not $files) {
    Write-Warning "⚠️ No Kotlin files found under $SourceRoot"
    exit 0
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $modified = $false

    # Check for existing package declaration
    $hasPackage = $content | Select-String -Pattern '^package\s'

    if (-Not $hasPackage) {
        # Guess package from relative path
        $relativePath = $file.FullName.Substring((Resolve-Path $SourceRoot).Path.Length + 1)
        $folderPath = Split-Path $relativePath -Parent
        $packageName = $folderPath -replace '\\','.' -replace '/','.'
        $packageName = $packageName -replace '.kt$','' -replace '\.','.' -replace '\.$',''

        if ($packageName) {
            $packageLine = "package $packageName"
            $content = @($packageLine) + "" + $content
            Write-Host "✅ Added package declaration: $packageName in $($file.Name)"
            $modified = $true
        } else {
            Write-Warning "⚠️ Could not determine package for $($file.Name)"
        }
    }

    # Clean duplicate or misplaced imports
    $cleaned = @()
    $foundImports = $false
    foreach ($line in $content) {
        if ($line.Trim().StartsWith("import ")) {
            $foundImports = $true
            $cleaned += $line.Trim()
        } elseif ($foundImports -and ($line -ne "")) {
            $cleaned += ""
            $cleaned += $line
        } else {
            $cleaned += $line
        }
    }

    if ($modified -or ($cleaned -ne $content)) {
        $cleaned | Set-Content $file.FullName
        Write-Host "✅ Fixed: $($file.FullName)"
    } else {
        Write-Host "✅ No changes needed: $($file.FullName)"
    }
}

Write-Host "------------------------------------------------------------"
Write-Host "🎯 DONE. Now run: ./gradlew clean assembleDebug"
Write-Host "------------------------------------------------------------"
