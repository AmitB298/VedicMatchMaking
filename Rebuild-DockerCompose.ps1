$composePath = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$backupPath = "$composePath.bak"

# Backup
Copy-Item $composePath $backupPath -Force
Write-Host "📦 Backup saved at $backupPath" -ForegroundColor Gray

# Rebuild content
$yaml = @"
version: '3.9'

services:
  api-gateway:
    build:
      context: ../services/api-gateway
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - PORT=3000
    volumes:
      - ../services/api-gateway:/usr/src/app
    depends_on:
      - user-service
      - matchmaking-service
      - community-service

  user-service:
    build:
      context: ../services/user-service
    ports:
      - "3001:3001"

  matchmaking-service:
    build:
      context: ../services/matchmaking-service
    ports:
      - "3002:3002"

  community-service:
    build:
      context: ../services/community-service
    ports:
      - "3003:3003"

  mongo:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"

volumes:
  mongo-data:
"@

# Write clean content
Set-Content -Path $composePath -Value $yaml -Encoding UTF8
Write-Host "✅ Rebuilt docker-compose.yml from scratch." -ForegroundColor Green

# Validate
Push-Location (Split-Path $composePath)
Write-Host "`n🧪 Validating..." -ForegroundColor Cyan
try {
    docker compose config | Out-Null
    Write-Host "✅ YAML is valid!" -ForegroundColor Green
} catch {
    Write-Error "❌ YAML is still invalid. Inspect structure manually."
}
Pop-Location
