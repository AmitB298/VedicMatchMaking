param(
    [string]$ServicePath = "."
)

Write-Host "🛠️  Starting Kundli Service Dockerfile fixer..."

$dockerfilePath = Join-Path $ServicePath "Dockerfile"
$backupPath = "$dockerfilePath.bak"

if (Test-Path $dockerfilePath) {
    Write-Host "🔎 Found existing Dockerfile. Backing it up..."
    Copy-Item -Path $dockerfilePath -Destination $backupPath -Force
    Write-Host "✅ Backup created at: $backupPath"
} else {
    Write-Host "⚠️ No existing Dockerfile found. Creating a new one."
}

$pythonDockerfile = @"
# ----------------------------------------------
# Auto-generated Dockerfile for Kundli Flask API
# ----------------------------------------------
FROM python:3.11-slim

WORKDIR /app

# Copy actual service code from parent kundli folder
COPY ../kundli .

# Install Python dependencies
RUN pip install -r requirements.txt

# Expose the Flask API port
EXPOSE 5055

# Start the Flask app
CMD ["python", "kundli_api.py"]
"@

$pythonDockerfile | Set-Content -Path $dockerfilePath -Force
Write-Host "✅ New Python Flask Dockerfile written to: $dockerfilePath"

Write-Host "🎯 Ready! Your kundli-service is now set up for Flask-based Docker build."
