param(
    [string]$RootPath
)
$path = Join-Path $RootPath "kundli-service"
New-Item -ItemType Directory -Path $path -Force | Out-Null

Set-Content -Path "$path\app.py" -Value @"
from flask import Flask, request, jsonify
app = Flask(__name__)
@app.route('/api/kundli', methods=['POST'])
def generate_kundli():
    data = request.json
    return jsonify({
        'status': 'success',
        'details': f'Advanced Kundli generated for {data.get("name", "Unknown")}'
    })
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
"@

Set-Content -Path "$path\requirements.txt" -Value "flask"
Set-Content -Path "$path\.env" -Value "PORT=3000"
Set-Content -Path "$path\Dockerfile" -Value @"
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 3000
CMD [ "python", "app.py" ]
"@

Write-Host "✅ Python Kundli microservice scaffold complete."
