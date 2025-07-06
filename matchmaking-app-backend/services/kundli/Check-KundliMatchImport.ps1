# Check-KundliMatchImport.ps1

$kundliFile = "kundli_match_full.py"
$functionName = "match_kundli"

Write-Host "🚀 Checking Python environment..."
python --version
Write-Host "Active environment path:"
Get-Command python | Select-Object Source

Write-Host "`n📂 Checking files in current directory..."
Get-ChildItem -File | ForEach-Object { Write-Host $_.Name }

if (-Not (Test-Path $kundliFile)) {
    Write-Error "❌ File '$kundliFile' not found in current directory."
    exit 1
}

Write-Host "`n🔍 Checking if function '$functionName' is defined inside '$kundliFile'..."
$content = Get-Content $kundliFile
$functionDefined = $false
foreach ($line in $content) {
    if ($line -match "def\s+$functionName\s*\(") {
        $functionDefined = $true
        break
    }
}

if ($functionDefined) {
    Write-Host "✅ Function '$functionName' found."
} else {
    Write-Warning "⚠️ Function '$functionName' NOT found in '$kundliFile'."
}

Write-Host "`n📄 Printing first 20 lines of '$kundliFile':"
Get-Content $kundliFile -TotalCount 20 | ForEach-Object { Write-Host $_ }

Write-Host "`n🐍 Testing Python import of '$functionName' from '$kundliFile'..."
$testScript = @"
try:
    from kundli_match_full import $functionName
    print('✅ Import successful')
except Exception as e:
    print('❌ Import failed:', e)
"@

$testScriptPath = ".\import_test.py"
$testScript | Out-File -FilePath $testScriptPath -Encoding utf8

python $testScriptPath

Remove-Item $testScriptPath

Write-Host "`n🔧 Script completed."
