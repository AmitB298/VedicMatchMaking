param(
    [Parameter(Mandatory=$true)]
    [string]$ServicePath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Kundli Production Setup"
Write-Host "------------------------------------------------------------"

# Validate path
if (!(Test-Path $ServicePath)) {
    Write-Error "❌ ERROR: The path $ServicePath does not exist."
    exit 1
}

# 1️⃣ Write app.py
$appPy = @'
from flask import Flask, request, jsonify
from kundli_service import KundliService

app = Flask(__name__)
service = KundliService()

@app.route('/')
def index():
    return jsonify({"status": "Kundli Service is running"}), 200

@app.route('/generate', methods=['POST'])
def generate_kundli():
    data = request.get_json()
    try:
        result = service.generate_kundli(
            data["birth_date"],
            data["birth_time"],
            data["latitude"],
            data["longitude"]
        )
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
'@
$appPy | Set-Content -Encoding UTF8 -Path (Join-Path $ServicePath "app.py")
Write-Host "✅ app.py written."

# 2️⃣ Write kundli_service.py
$kundliServicePy = @'
import swisseph as swe
from datetime import datetime

class KundliService:
    def __init__(self, ephe_path="swiss_ephe"):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, birth_date, birth_time, latitude, longitude):
        dt = datetime.strptime(f"{birth_date} {birth_time}", "%Y-%m-%d %H:%M:%S")
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {}
        for i in range(swe.SUN, swe.PLUTO + 1):
            pos, _ = swe.calc_ut(jd, i)
            planets[swe.get_planet_name(i)] = pos
        asc = swe.houses(jd, latitude, longitude, b'P')[1][0]
        return {
            "planets": planets,
            "ascendant": asc,
            "birth_details": {
                "date": birth_date,
                "time": birth_time,
                "latitude": latitude,
                "longitude": longitude
            }
        }
'@
$kundliServicePy | Set-Content -Encoding UTF8 -Path (Join-Path $ServicePath "kundli_service.py")
Write-Host "✅ kundli_service.py written."

# 3️⃣ Write requirements.txt
$requirements = @'
Flask
pyswisseph
'@
$requirements | Set-Content -Encoding UTF8 -Path (Join-Path $ServicePath "requirements.txt")
Write-Host "✅ requirements.txt written."

# 4️⃣ Write Dockerfile
$dockerfile = @'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
'@
$dockerfile | Set-Content -Encoding UTF8 -Path (Join-Path $ServicePath "Dockerfile")
Write-Host "✅ Dockerfile written."

Write-Host "------------------------------------------------------------"
Write-Host "✅ All production-ready files written to $ServicePath"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "   1. cd $ServicePath"
Write-Host "   2. docker build -t kundli-service ."
Write-Host "   3. docker run -d --name kundli-service-container -p 5000:5000 kundli-service"
Write-Host "------------------------------------------------------------"
