param(
    [Parameter(Mandatory = $true)]
    [string]$RootPath,
    
    [switch]$Force
)

# Helper logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "------------------------------------------------------------"
Write-Log "✅ VedicMatchmaking Python Kundli Microservice Scaffolder STARTED"
Write-Log "------------------------------------------------------------"
Write-Log "📂 Target Root: $RootPath"

# Define folders
$folders = @(
    "controllers",
    "services",
    "utils",
    "routes"
)

# Create root folder if it doesn't exist
if (!(Test-Path $RootPath)) {
    New-Item -ItemType Directory -Path $RootPath | Out-Null
    Write-Log "Created root directory: $RootPath" "SUCCESS"
}

# Create subfolders
foreach ($folder in $folders) {
    $path = Join-Path $RootPath $folder
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Log "Created: $path" "SUCCESS"
    }
}

# Helper to write content
function Write-File {
    param (
        [string]$FilePath,
        [string]$Content
    )
    if ((Test-Path $FilePath) -and !$Force) {
        Write-Log "Skipped existing file (use -Force to overwrite): $FilePath" "WARNING"
    } else {
        $Content | Out-File -Encoding UTF8 -FilePath $FilePath -Force
        Write-Log "Generated file: $FilePath" "SUCCESS"
    }
}

# Main app.py
$appPy = @"
from flask import Flask
from routes.kundli_routes import kundli_bp

app = Flask(__name__)
app.register_blueprint(kundli_bp, url_prefix='/api/kundli')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
"@
Write-File (Join-Path $RootPath "app.py") $appPy

# Routes
$routes = @"
from flask import Blueprint, request, jsonify
from controllers.kundli_controller import generate_kundli

kundli_bp = Blueprint('kundli', __name__)

@kundli_bp.route('/generate', methods=['POST'])
def generate():
    data = request.json
    result = generate_kundli(data)
    return jsonify(result)
"@
Write-File (Join-Path $RootPath "routes\kundli_routes.py") $routes

# Controller
$controller = @"
from services.kundli_service import calculate_kundli

def generate_kundli(data):
    return calculate_kundli(data)
"@
Write-File (Join-Path $RootPath "controllers\kundli_controller.py") $controller

# Service
$service = @"
from utils.swisseph_utils import get_detailed_chart

def calculate_kundli(user_data):
    return get_detailed_chart(user_data)
"@
Write-File (Join-Path $RootPath "services\kundli_service.py") $service

# Utils
$utils = @"
# Example Swiss Ephemeris utility
def get_detailed_chart(data):
    # You'd integrate swisseph or pyswisseph here
    return {
        'ascendant': 'Aries',
        'moonSign': 'Taurus',
        'nakshatra': 'Rohini',
        'chartDetails': 'Very detailed advanced chart data here'
    }
"@
Write-File (Join-Path $RootPath "utils\swisseph_utils.py") $utils

# requirements.txt
$requirements = @"
Flask
pyswisseph
python-dotenv
"@
Write-File (Join-Path $RootPath "requirements.txt") $requirements

# .env.example
$envFile = @"
FLASK_ENV=development
PORT=5000
"@
Write-File (Join-Path $RootPath ".env.example") $envFile

# Dockerfile
$dockerfile = @"
FROM python:3.10-slim

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
"@
Write-File (Join-Path $RootPath "Dockerfile") $dockerfile

Write-Log "✅ Python Kundli microservice scaffold complete."
Write-Log "------------------------------------------------------------"
Write-Log "✅ All tasks complete."
Write-Log "------------------------------------------------------------"
