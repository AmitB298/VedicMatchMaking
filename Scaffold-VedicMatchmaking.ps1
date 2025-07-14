<#
.SYNOPSIS
    Scaffolds the full VedicMatchmaking monorepo.

.DESCRIPTION
    - Creates folders and templates for:
        - Node.js Backend
        - Python Kundli Service
        - React Web Frontend
        - Android App placeholder
    - Writes unified .env and Dockerfiles
    - Creates project-config.json

.PARAMETER RootPath
    The root folder where to scaffold.

.EXAMPLE
    .\Scaffold-VedicMatchmaking.ps1 -RootPath "E:\VedicCouple"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$RootPath
)

function Write-FileSafe {
    param(
        [string]$Path,
        [string]$Content
    )
    if (!(Test-Path $Path)) {
        $Content | Out-File -Encoding UTF8 -FilePath $Path
        Write-Host "✅ Created: $Path"
    } else {
        Write-Host "⚠️  Exists: $Path (Skipped)"
    }
}

function New-EnvFile {
    param($Path)
    $envContent = @"
# Common Environment Variables
MONGODB_URI=mongodb://localhost:27017/vedicmatch
KUNDLI_SERVICE_URL=http://localhost:5001
PORT=3000
"@
    Write-FileSafe $Path $envContent
}

function New-DockerfileNode {
    param($Path)
    $dockerContent = @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
"@
    Write-FileSafe $Path $dockerContent
}

function New-DockerfilePython {
    param($Path)
    $dockerContent = @"
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5001
CMD [ "python", "app.py" ]
"@
    Write-FileSafe $Path $dockerContent
}

function New-DockerfileWeb {
    param($Path)
    $dockerContent = @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
"@
    Write-FileSafe $Path $dockerContent
}

function Scaffold-Backend {
    $dir = Join-Path $RootPath "backend"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-FileSafe "$dir\server.js" @"
const express = require('express');
require('dotenv').config();
const app = express();
app.use(express.json());
app.get('/', (req, res) => res.send('✅ Backend Running'));
app.listen(process.env.PORT || 3000, () => console.log(\`✅ Backend listening on port \${process.env.PORT || 3000}\`));
"@
    Write-FileSafe "$dir\package.json" @"
{
  "name": "vedicmatch-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": { "start": "node server.js" },
  "dependencies": { "express": "^4.18.0", "dotenv": "^16.0.0" }
}
"@
    New-EnvFile "$dir\.env"
    New-DockerfileNode "$dir\Dockerfile"
}

function Scaffold-KundliService {
    $dir = Join-Path $RootPath "kundli-service"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-FileSafe "$dir\app.py" @"
from flask import Flask, request, jsonify
app = Flask(__name__)
@app.route('/')
def index():
    return '✅ Kundli Service Running'
@app.route('/api/kundli', methods=['POST'])
def generate_kundli():
    data = request.json
    return jsonify({"message": "Kundli generated", "input": data})
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
"@
    Write-FileSafe "$dir\requirements.txt" @"
flask
pyswisseph
"@
    New-EnvFile "$dir\.env"
    New-DockerfilePython "$dir\Dockerfile"
}

function Scaffold-Web {
    $dir = Join-Path $RootPath "web"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-FileSafe "$dir\README.md" "# React Web Frontend for VedicMatch"
    New-EnvFile "$dir\.env"
    New-DockerfileWeb "$dir\Dockerfile"
}

function Scaffold-Android {
    $dir = Join-Path $RootPath "android"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-FileSafe "$dir\README.md" @"
# Android App
✅ Jetpack Compose placeholder
- Call same API
- Use Kotlin, Hilt, Retrofit
"@
}

function Write-ProjectConfig {
    $config = @{
        Name = "VedicMatchMaking"
        Services = @("backend", "kundli-service", "web", "android")
        DockerNamespace = "yourdockerusername"
        Version = "1.0.0"
    } | ConvertTo-Json -Depth 4
    Write-FileSafe (Join-Path $RootPath "project-config.json") $config
}

Write-Host "------------------------------------------------------------"
Write-Host "✅ VedicMatchmaking Advanced Scaffolder"
Write-Host "------------------------------------------------------------"
Write-Host "🕒 Timestamp: $(Get-Date)"
Write-Host "📂 Target Root: $RootPath"
Write-Host "------------------------------------------------------------"

Scaffold-Backend
Scaffold-KundliService
Scaffold-Web
Scaffold-Android
Write-ProjectConfig

Write-Host "------------------------------------------------------------"
Write-Host "✅ All scaffolding complete!"
Write-Host "------------------------------------------------------------"
