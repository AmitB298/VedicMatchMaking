# Train-KundliAIMatcher.ps1
$ErrorActionPreference = "Stop"
$pythonPath = ".\venv\Scripts\python.exe"
$modelPath = "models\kundli_match_predictor.pkl"
$trainScript = "train_kundli_model.py"
$logFile = "train_log.txt"

Write-Host "🧠 Training AI Kundli Match Predictor..."

# Step 1: Ensure 'models/' exists
if (!(Test-Path "models")) {
    New-Item -ItemType Directory -Path "models" | Out-Null
}

# Step 2: Check Internet
Write-Host "🌐 Checking internet connectivity..."
try {
    $null = Invoke-WebRequest -Uri "https://pypi.org" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Internet access confirmed."
} catch {
    Write-Host "❌ No internet access. Cannot install required packages." -ForegroundColor Red
    exit 1
}

# Step 3: Install required packages with live output
Write-Host "`n📦 Installing Python packages (pandas, scikit-learn, joblib)..."
try {
    & $pythonPath -m pip install --upgrade pip setuptools wheel
    & $pythonPath -m pip install pandas scikit-learn joblib
} catch {
    Write-Host "❌ pip install failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Check if training script exists
if (!(Test-Path $trainScript)) {
    Write-Host "❌ Training script '$trainScript' not found." -ForegroundColor Red
    exit 1
}

# Step 5: Run training and capture logs
Write-Host "`n🚀 Running training script..."
try {
    & $pythonPath $trainScript *>> $logFile
    if (Test-Path $modelPath) {
        Write-Host "✅ Model trained and saved to '$modelPath'."
    } else {
        Write-Host "❌ Model training ran but output model not found." -ForegroundColor Red
        Get-Content $logFile -Tail 20
        exit 1
    }
} catch {
    Write-Host "❌ Training failed with exception: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path $logFile) {
        Write-Host "`n🔍 Log tail from '$logFile':"
        Get-Content $logFile -Tail 20
    }
    exit 1
}

Write-Host "`n📄 Full training log saved to $logFile"
