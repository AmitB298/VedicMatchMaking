# Fix-KundliAIMatcher.ps1

$scriptPath = "kundli_ai_matcher.py"
$modelPath = "models/kundli_match_predictor.pkl"

Write-Host "🔍 Checking $scriptPath ..."

if (-Not (Test-Path $scriptPath)) {
    Write-Error "❌ $scriptPath not found."
    exit 1
}

# Load script content
$content = Get-Content $scriptPath -Raw -Encoding UTF8

# Step 1: Replace RAHU and KETU with proper logic
$content = $content -replace 'swe\.RAHU', 'swe.MEAN_NODE'
$content = $content -replace 'swe\.KETU', '# Ketu will be calculated manually'

# Step 2: Inject Ketu logic (if not already present)
if ($content -notmatch 'planet_positions\["Ketu"\]') {
    $ketuCode = @"
    # Add RAHU and KETU positions
    rahu_pos, _ = swe.calc_ut(jd, swe.MEAN_NODE, flag)
    planet_positions["Rahu"] = rahu_pos[0]
    planet_positions["Ketu"] = (rahu_pos[0] + 180) % 360
"@
    $content = $content -replace '(planet_positions\s*=\s*{[^}]*})', "`$1`n$ketuCode"
    Write-Host "✅ Injected Rahu/Ketu calculation logic."
}

# Step 3: Inject model fallback logic
if ($content -match 'joblib\.load') {
    $fallback = @"
try:
    self.model = joblib.load('models/kundli_match_predictor.pkl')
except FileNotFoundError:
    print("[ML] Warning: Could not load model. Using fallback logic.")
    self.model = None
"@
    $content = $content -replace 'self\.model\s*=\s*joblib\.load.*?\n', "$fallback`n"
    Write-Host "✅ Added fallback model handling."
}

# Step 4: Write back fixed content
$content | Set-Content $scriptPath -Encoding UTF8
Write-Host "💾 Updated $scriptPath successfully."

# Step 5: Check if model file exists
if (-Not (Test-Path $modelPath)) {
    Write-Host "⚠️  Model file not found at '$modelPath'. Creating placeholder..."
    New-Item -ItemType Directory -Force -Path (Split-Path $modelPath)
    python -c @"
import joblib
from sklearn.linear_model import LogisticRegression
model = LogisticRegression()
joblib.dump(model, '$modelPath')
"@
    Write-Host "✅ Dummy model created: $modelPath"
}

Write-Host "`n🎉 All fixes applied. You can now run: python kundli_ai_matcher.py"
