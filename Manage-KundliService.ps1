param(
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kundli Service Setup and Runner"
Write-Host "------------------------------------------------------------"

# Prompt if path not supplied
if (-not $ServicePath) {
    $ServicePath = Read-Host "Enter the full path to your Kundli service folder"
}

# Check path
if (!(Test-Path $ServicePath)) {
    Write-Host "❌ ERROR: Path does not exist: $ServicePath" -ForegroundColor Red
    exit 1
}

Set-Location $ServicePath
Write-Host "📂 Changed directory to: $ServicePath"

# Check for venv
$venvPath = Join-Path $ServicePath "venv"
if (!(Test-Path $venvPath)) {
    Write-Host "⚠️ Virtual environment not found. Creating it..."
    python -m venv venv
    if (!(Test-Path $venvPath)) {
        Write-Host "❌ ERROR: Failed to create virtual environment." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Virtual environment created at: $venvPath"
} else {
    Write-Host "✅ Virtual environment exists: $venvPath"
}

# Activate venv
Write-Host "⚙️ Activating virtual environment..."
& "$venvPath\Scripts\Activate"

# Upgrade pip
Write-Host "⬆️ Upgrading pip..."
python -m pip install --upgrade pip

# Install requirements
Write-Host "📦 Installing dependencies from requirements.txt..."
pip install -r requirements.txt

Write-Host "✅ Dependencies installed."

# Ask to run server
$runServer = Read-Host "Do you want to start the Flask server now? (y/n)"
if ($runServer -eq "y" -or $runServer -eq "Y") {
    Write-Host "🚀 Launching Flask server on port 5000..."
    python app.py
} else {
    Write-Host "✅ Setup complete. Server not started."
}

Write-Host "------------------------------------------------------------"
Write-Host "✅ All tasks completed."
Write-Host "------------------------------------------------------------"
