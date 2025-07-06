# Handle-MongoPortError.ps1
param (
    [string]$MongoHost = "localhost",
    [int]$MongoPort = 27017,
    [switch]$LaunchMongoExpress = $false
)

function Test-MongoHTTP {
    try {
        $response = Invoke-WebRequest -Uri "http://$MongoHost:$MongoPort" -UseBasicParsing -TimeoutSec 5
        if ($response.Content -match "trying to access MongoDB over HTTP") {
            Write-Warning "❌ You tried to access MongoDB via HTTP on port $MongoPort"
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Host "✅ MongoDB is not responding to HTTP on port $MongoPort — this is expected." -ForegroundColor Green
        return $false
    }
}

function Start-MongoExpress {
    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "❌ Docker is not installed or not in PATH."
        return
    }

    $existing = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq "mongo-express" }
    if ($existing) {
        Write-Host "🔁 Starting existing mongo-express container..."
        docker start mongo-express
    } else {
        Write-Host "🚀 Launching mongo-express on http://localhost:8081 ..."
        docker run -d -p 8081:8081 --name mongo-express `
            -e ME_CONFIG_MONGODB_SERVER=$MongoHost `
            mongo-express
    }
}

function Check-MongoNativeConnection {
    if (Get-Command mongosh -ErrorAction SilentlyContinue) {
        Write-Host "🔍 Checking native MongoDB connection via mongosh..."
        mongosh --quiet --eval "db.stats()" --host $MongoHost --port $MongoPort
    } else {
        Write-Warning "⚠️ 'mongosh' not found. Install MongoDB CLI for native connection testing."
    }
}

# --- MAIN LOGIC ---
Write-Host "🔍 Checking MongoDB on $MongoHost:$MongoPort ..."
if (Test-MongoHTTP) {
    Write-Host "`n📌 FIX:"
    Write-Host "➡️  Use MongoDB drivers, mongosh, Compass, or a GUI like Mongo Express instead of HTTP" -ForegroundColor Yellow
    if ($LaunchMongoExpress) {
        Start-MongoExpress
    }
} else {
    Write-Host "✅ MongoDB is not misused over HTTP." -ForegroundColor Green
}

Check-MongoNativeConnection
