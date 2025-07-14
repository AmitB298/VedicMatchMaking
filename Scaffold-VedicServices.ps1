<#
.SYNOPSIS
  Generates complete, production-ready service folders for 'web' and 'backend'
.DESCRIPTION
  - Fixes broken server.js with valid code
  - Adds minimal package.json with express
  - Adds production-ready Dockerfile
  - Adds .dockerignore
.PARAMETER RootPath
  Path to the project root (default: current location)
#>

param(
    [string]$RootPath = (Get-Location)
)

$services = @('web','backend')

Write-Host "------------------------------------------------------------"
Write-Host "✅ VedicMatchMaking Service Scaffolder"
Write-Host "------------------------------------------------------------"
Write-Host "🕒 Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "📂 Root Path: $RootPath"
Write-Host ""

# Define content templates
$serverJS = @'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('✅ Service is running!');
});

app.listen(PORT, () => {
  console.log(`✅ Service listening on port ${PORT}`);
});
'@

$packageJSON = @'
{
  "name": "{SERVICE_NAME}",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
'@

$dockerfile = @'
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
'@

$dockerignore = @'
node_modules
npm-debug.log
'@

# Loop through services
foreach ($service in $services) {
    $servicePath = Join-Path $RootPath $service

    if (-Not (Test-Path $servicePath)) {
        Write-Host "✅ Creating folder: $servicePath"
        New-Item -ItemType Directory -Path $servicePath | Out-Null
    } else {
        Write-Host "⚠️  Folder already exists: $servicePath"
    }

    # Write server.js
    Set-Content -Path (Join-Path $servicePath "server.js") -Value $serverJS -Encoding UTF8
    Write-Host "✅ Created: server.js"

    # Write package.json
    $pkg = $packageJSON.Replace("{SERVICE_NAME}", "vedicmatch-$service")
    Set-Content -Path (Join-Path $servicePath "package.json") -Value $pkg -Encoding UTF8
    Write-Host "✅ Created: package.json"

    # Write Dockerfile
    Set-Content -Path (Join-Path $servicePath "Dockerfile") -Value $dockerfile -Encoding UTF8
    Write-Host "✅ Created: Dockerfile"

    # Write .dockerignore
    Set-Content -Path (Join-Path $servicePath ".dockerignore") -Value $dockerignore -Encoding UTF8
    Write-Host "✅ Created: .dockerignore"

    Write-Host "------------------------------------------------------------"
}

Write-Host "✅ All services scaffolded successfully!"
Write-Host "------------------------------------------------------------"
