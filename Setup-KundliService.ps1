param(
    [string]$ServicePath
)

if (-not $ServicePath) {
    $ServicePath = Read-Host "Enter the full path for the Kundli Service"
}

if (!(Test-Path $ServicePath)) {
    Write-Host "📦 Creating folder at: $ServicePath"
    New-Item -Path $ServicePath -ItemType Directory -Force | Out-Null
}

# Dockerfile
@"
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
"@ | Set-Content -Encoding UTF8 -Path "$ServicePath\Dockerfile"

Write-Host "✅ Dockerfile created."

# requirements.txt
@"
Flask
pyswisseph
"@ | Set-Content -Encoding UTF8 -Path "$ServicePath\requirements.txt"

Write-Host "✅ requirements.txt created."

# kundli_service.py
@"
import swisseph as swe
from datetime import datetime

class KundliService:
    def __init__(self, ephe_path='swiss_ephe'):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, dob, tob, latitude, longitude):
        dt = datetime.strptime(f"{dob} {tob}", "%Y-%m-%d %H:%M:%S")
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {}
        for i in range(swe.SUN, swe.PLUTO + 1):
            pos = swe.calc_ut(jd, i)[0]
            planets[swe.get_planet_name(i)] = pos
        asc = swe.houses(jd, latitude, longitude, b'P')[1][0]
        return {
            "planets": planets,
            "ascendant": asc
        }

def match_kundlis(boy, girl):
    guna_breakdown = [
        {
            "name": "Bhakoot",
            "score": 7,
            "max_score": 7,
            "sub_parts": [
                {"label": "Rashi Lord compatibility", "matched": True},
                {"label": "Rashi distance", "matched": True}
            ]
        },
        {
            "name": "Nadi",
            "score": 8,
            "max_score": 8,
            "sub_parts": [
                {"label": "Prakriti", "matched": True},
                {"label": "Dosha", "matched": True}
            ]
        },
        {
            "name": "Gana",
            "score": 5,
            "max_score": 6,
            "sub_parts": [
                {"label": "Nature difference", "matched": False}
            ]
        }
    ]
    overall_score = sum(g["score"] for g in guna_breakdown)
    max_score = sum(g["max_score"] for g in guna_breakdown)
    result_text = "✅ Excellent Match" if overall_score >= 27 else ("⚠️ Moderate Match" if overall_score >= 18 else "❌ Low Compatibility")
    remedies = []
    if overall_score < 27:
        remedies.append("Perform Navagraha Shanti")
        remedies.append("Wear Yellow Sapphire")
    return {
        "overall_score": overall_score,
        "max_score": max_score,
        "result_text": result_text,
        "guna_breakdown": guna_breakdown,
        "remedies": remedies
    }
"@ | Set-Content -Encoding UTF8 -Path "$ServicePath\kundli_service.py"

Write-Host "✅ kundli_service.py created."

# app.py
@"
from flask import Flask, request, jsonify
from kundli_service import KundliService, match_kundlis

app = Flask(__name__)
kundli_service = KundliService()

@app.route('/api/generate_kundli', methods=['POST'])
def generate_kundli():
    data = request.json
    kundli = kundli_service.generate_kundli(
        data.get('dob'),
        data.get('tob'),
        data.get('latitude'),
        data.get('longitude')
    )
    response = {
        "status": "success",
        "kundli": {
            "name": data.get('name'),
            "caste": data.get('caste'),
            "birth_details": {
                "dob": data.get('dob'),
                "tob": data.get('tob'),
                "latitude": data.get('latitude'),
                "longitude": data.get('longitude')
            },
            "planets": kundli["planets"],
            "ascendant": kundli["ascendant"]
        }
    }
    return jsonify(response)

@app.route('/api/match_kundli', methods=['POST'])
def match_kundli():
    data = request.json
    boy = kundli_service.generate_kundli(
        data['boy']['dob'],
        data['boy']['tob'],
        data['boy']['latitude'],
        data['boy']['longitude']
    )
    girl = kundli_service.generate_kundli(
        data['girl']['dob'],
        data['girl']['tob'],
        data['girl']['latitude'],
        data['girl']['longitude']
    )
    match_result = match_kundlis(boy, girl)
    return jsonify({"status": "success", **match_result})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
"@ | Set-Content -Encoding UTF8 -Path "$ServicePath\app.py"

Write-Host "------------------------------------------------------------"
Write-Host "✅ Kundli Service Setup Complete at: $ServicePath"
Write-Host "------------------------------------------------------------"
