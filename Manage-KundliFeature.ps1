param(
    [switch]$Init,
    [switch]$Scaffold,
    [switch]$Install,
    [switch]$Build,
    [switch]$Run,
    [switch]$SeedDB,
    [switch]$OpenFrontend,
    [switch]$Clean
)

# --------------------------------------------
function Check-Docker {
    Write-Host "✅ Checking Docker..."
    try {
        docker info | Out-Null
        Write-Host "✅ Docker is running!"
    } catch {
        Write-Error "❌ Docker is NOT running. Please start Docker Desktop."
        exit 1
    }
}
# --------------------------------------------

if ($Init) {
    Write-Host "✅ Initializing Repo..."
    git init
    git add .
    git commit -m "Initial commit" -ErrorAction SilentlyContinue
    Write-Host "✅ Git repo initialized."
}

if ($Scaffold) {
    Write-Host "✅ Scaffolding Services..."

    # NODE BACKEND
    New-Item -Path ".\node-backend" -ItemType Directory -Force | Out-Null
    Set-Content ".\node-backend\server.js" 'console.log("✅ Node Backend listening on port 3000");'
    Set-Content ".\node-backend\package.json" '{
  "name": "node-backend",
  "version": "1.0.0",
  "scripts": { "start": "node server.js" },
  "dependencies": {}
}'
    Set-Content ".\node-backend\Dockerfile" @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
"@

    # PYTHON KUNDLI SERVICE
    New-Item -Path ".\kundli-service" -ItemType Directory -Force | Out-Null
    Set-Content ".\kundli-service\app.py" 'print("✅ Kundli Python Service listening on port 5000")'
    Set-Content ".\kundli-service\requirements.txt" "flask"
    Set-Content ".\kundli-service\Dockerfile" @"
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD [ "python", "app.py" ]
"@

    # REACT FRONTEND
    New-Item -Path ".\web-frontend" -ItemType Directory -Force | Out-Null
    Set-Content ".\web-frontend\package.json" '{
  "name": "web-frontend",
  "version": "1.0.0",
  "scripts": { "start": "echo \"Starting React App (placeholder)\" && sleep infinity" },
  "dependencies": {}
}'
    Set-Content ".\web-frontend\Dockerfile" @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
"@

    # DOCKER COMPOSE
    Set-Content ".\docker-compose.yml" @"
version: '3.8'
services:
  node-backend:
    build: ./node-backend
    ports:
      - "3001:3000"
  kundli-service:
    build: ./kundli-service
    ports:
      - "5000:5000"
  web-frontend:
    build: ./web-frontend
    ports:
      - "3000:3000"
  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:
"@

    Write-Host "✅ Scaffolding Complete."
}

if ($Install) {
    Write-Host "✅ Installing Node & Python Dependencies..."
    if (Test-Path ".\node-backend") {
        cd .\node-backend
        npm install
        cd ..
    }
    if (Test-Path ".\kundli-service") {
        cd .\kundli-service
        pip install -r requirements.txt
        cd ..
    }
    if (Test-Path ".\web-frontend") {
        cd .\web-frontend
        npm install
        cd ..
    }
    Write-Host "✅ Dependencies Installed."
}

if ($Build) {
    Check-Docker
    Write-Host "✅ Building Docker Images..."
    docker-compose build
    Write-Host "✅ Build Complete."
}

if ($Run) {
    Check-Docker
    Write-Host "✅ Starting All Services..."
    docker-compose up -d
    Write-Host "✅ All Services Running."
}

if ($SeedDB) {
    Check-Docker
    Write-Host "✅ Seeding MongoDB..."
    $mongoContainer = (docker ps --filter "ancestor=mongo:6" --format "{{.ID}}")
    if ($mongoContainer) {
        docker exec -i $mongoContainer mongosh --eval "db.users.insert({ name: 'Sample User', kundli: 'Sample Kundli Data' })"
        Write-Host "✅ Database Seeded."
    } else {
        Write-Host "❌ MongoDB container not found."
    }
}

if ($OpenFrontend) {
    Write-Host "✅ Opening Frontend in Browser..."
    Start-Process "http://localhost:3000"
}

if ($Clean) {
    Check-Docker
    Write-Host "✅ Stopping Containers..."
    docker-compose down -v
    Write-Host "✅ Removing dangling images & cache..."
    docker system prune -a -f
    Write-Host "✅ Cleanup Complete."
}
