param(
    [string]$RootPath
)
$path = Join-Path $RootPath "web"
New-Item -ItemType Directory -Path $path -Force | Out-Null

Set-Content -Path "$path\README.md" -Value "# VedicMatchmaking Web Frontend"
Set-Content -Path "$path\.env" -Value "REACT_APP_API_URL=http://localhost:3001"
Set-Content -Path "$path\Dockerfile" -Value @"
FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
"@

Write-Host "✅ React Web Frontend scaffold complete."
