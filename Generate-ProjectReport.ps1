<#
.SYNOPSIS
    Fast project analyzer that skips excluded folders *before* recursing.
#>

param(
    [string]$ProjectPath = "E:\VedicMatchMaking"
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = Join-Path $ProjectPath "ProjectReport_$timestamp.txt"

$excludeDirs = @("node_modules", ".git", "build", "dist", ".gradle", ".idea", "venv")

"------------------------------------------------------------" | Out-File $reportFile
"🗂️ Project Analysis Report for $ProjectPath" | Out-File $reportFile -Append
"Generated at: $(Get-Date)" | Out-File $reportFile -Append
"------------------------------------------------------------`n" | Out-File $reportFile -Append

# Recursive enumerator that respects excludes
function Get-CustomFiles {
    param (
        [string]$Path
    )
    $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            if ($excludeDirs -contains $item.Name) {
                continue
            }
            Get-CustomFiles -Path $item.FullName
        } else {
            $item
        }
    }
}

function Get-CustomDirs {
    param (
        [string]$Path
    )
    $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            if ($excludeDirs -contains $item.Name) {
                continue
            }
            $item
            Get-CustomDirs -Path $item.FullName
        }
    }
}

# 1. Folder Tree
"📂 Folder Tree (excluding big folders):" | Out-File $reportFile -Append
Get-CustomDirs -Path $ProjectPath | ForEach-Object {
    $_.FullName
} | Out-File $reportFile -Append
"`n" | Out-File $reportFile -Append

# 2. File Details
"📑 File Details (excluding big folders):" | Out-File $reportFile -Append
Get-CustomFiles -Path $ProjectPath | Sort-Object FullName | ForEach-Object {
    $sizeMB = "{0:N2}" -f ($_.Length / 1MB)
    $lastWrite = $_.LastWriteTime
    "{0}`t{1} MB`t{2}" -f $_.FullName, $sizeMB, $lastWrite
} | Out-File $reportFile -Append
"`n" | Out-File $reportFile -Append

# 3. File Extension Summary
"📊 File Extensions Summary:" | Out-File $reportFile -Append
Get-CustomFiles -Path $ProjectPath | Group-Object Extension | ForEach-Object {
    "{0}`tCount: {1}" -f $_.Name, $_.Count
} | Sort-Object | Out-File $reportFile -Append
"`n" | Out-File $reportFile -Append

# 4. Large Files
"⚠️ Large Files (>10MB):" | Out-File $reportFile -Append
Get-CustomFiles -Path $ProjectPath | Where-Object { $_.Length -gt 10MB } | ForEach-Object {
    "{0}  Size: {1:N2} MB" -f $_.FullName, ($_.Length / 1MB)
} | Out-File $reportFile -Append
"`n" | Out-File $reportFile -Append

# 5. Line Counts
"📝 Line Counts (Text / Code):" | Out-File $reportFile -Append
$codeExts = ".ps1", ".js", ".ts", ".json", ".html", ".css", ".java", ".kt", ".py", ".md", ".yaml", ".yml"
Get-CustomFiles -Path $ProjectPath | Where-Object { $codeExts -contains $_.Extension } | ForEach-Object {
    try {
        $lines = (Get-Content $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
        "{0}`tLines: {1}" -f $_.FullName, $lines
    } catch {
        "{0}`tLines: ERROR" -f $_.FullName
    }
} | Out-File $reportFile -Append
"`n" | Out-File $reportFile -Append

# 6. Total Size
$totalSize = (Get-CustomFiles -Path $ProjectPath | Measure-Object Length -Sum).Sum / 1MB
"📦 Total Project Size (excluding big folders): {0:N2} MB" -f $totalSize | Out-File $reportFile -Append

"✅ Report saved to: $reportFile"
