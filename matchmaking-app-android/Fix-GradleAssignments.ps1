param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Fixing Gradle Groovy DSL Deprecated Assignments (Safe Mode)"
Write-Host "------------------------------------------------------------"

if (!(Test-Path $FilePath)) {
    Write-Error "❌ File not found: $FilePath"
    exit 1
}

# Load entire file (cross-version compatible)
$linesArray = (Get-Content -Path $FilePath -Raw -Encoding UTF8) -split "`r?`n"

$insidePluginsBlock = $false
$fixedLines = @()

# Regex to match property assignment without '='
$pattern = "^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s+(['`"]).*"

foreach ($line in $linesArray) {
    $trimmed = $line.Trim()

    # Detect start of plugins block
    if ($trimmed -match '^\s*plugins\s*\{') {
        $insidePluginsBlock = $true
    }
    elseif ($insidePluginsBlock -and $trimmed -eq '}') {
        $insidePluginsBlock = $false
    }

    if ($insidePluginsBlock) {
        # Leave plugins block untouched
        $fixedLines += $line
        continue
    }

    if ($trimmed -match $pattern -and $trimmed -notmatch '=') {
        # Only fix if it lacks '='
        $fixedLine = [regex]::Replace($line, $pattern, '$1 = $2')
        $fixedLines += $fixedLine
    }
    else {
        $fixedLines += $line
    }
}

# Save result back
Set-Content -Path $FilePath -Value $fixedLines -Encoding UTF8

Write-Host "✅ Fix applied successfully to: $FilePath"
Write-Host "------------------------------------------------------------"
