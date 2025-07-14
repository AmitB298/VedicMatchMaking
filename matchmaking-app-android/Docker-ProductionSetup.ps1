<#
.SYNOPSIS
  Production-ready Docker setup script for Node.js.
.DESCRIPTION
  Automates .dockerignore, builds image, tags properly, pushes to Docker Hub with user-supplied namespace.
.PARAMETER Force
  Overwrites existing .dockerignore if present.
.EXAMPLE
  .\Docker-ProductionSetup.ps1 -Force
#>

param(
    [switch]$Force
)

$LogFile = Join-Path $PWD "docker-production-setup-log.txt"
$Log = @()

function Log {
    param([string]$Message)
    Write-Host $Message
    $Log += $Message
}

function Save-Log {
    $Log | Out-File -Encoding utf8 -FilePath $LogFile
}

function Abort {
    param([string]$Message)
    Log "❌ ERROR: $Message"
    Save-Log
    exit 1
}

Log "------------------------------------------------------------"
Log "✅ Docker Production Setup Script"
Log "------------------------------------------------------------"
Log "🕒 Timestamp: $(Get-Date)"
Log "📂 Working Directory: $PWD"

# 1️⃣ Check Docker CLI
try {
    $dockerVersion = docker --version
    Log "✔️ Docker CLI found: $dockerVersion"
} catch {
    Abort "Docker CLI not found. Please install Docker Desktop first."
}

# 2️⃣ Check Docker Daemon
try {
    $dockerInfo = docker info 2>&1
    if ($dockerInfo -match "error during connect") {
        Abort "Docker daemon not responding. Start Docker Desktop and ensure it's running."
    } else {
        Log "✔️ Docker daemon is responsive."
    }
} catch {
    Abort "Could not verify Docker daemon. Ensure Docker Desktop is installed and running."
}

# 3️⃣ Check package-lock.json
if (!(Test-Path "package-lock.json")) {
    Abort "package-lock.json not found. Run 'npm install' before building."
}
Log "✔️ Found package-lock.json"
Log "✅ REMINDER: Commit package-lock.json to source control for reproducible builds."

# 4️⃣ Generate .dockerignore
$DockerignorePath = Join-Path $PWD ".dockerignore"

if ((Test-Path $DockerignorePath) -and (-not $Force)) {
    Log "✔️ .dockerignore already exists. Skipping creation."
    Log "➡️ Tip: Use -Force to overwrite."
} else {
    if ((Test-Path $DockerignorePath) -and $Force) {
        Log "⚠️ Overwriting existing .dockerignore (because -Force is set)."
    }
    Log "✅ Generating .dockerignore..."
    $dockerignoreContent = @"
node_modules
npm-debug.log
Dockerfile
*.md
.git
.gitignore
.DS_Store
.env
.env.*
logs
*.log
coverage
"@
    try {
        $dockerignoreContent | Out-File -Encoding utf8 -FilePath $DockerignorePath -Force
        Log "✅ .dockerignore created at: $DockerignorePath"
    } catch {
        Abort "Failed to write .dockerignore. Check permissions."
    }
}

# 5️⃣ Ask for image name and version
$defaultName = "vedicmatchmaking-web"
$imageName = Read-Host "❓ Enter image name (default: $defaultName)"
if ([string]::IsNullOrWhiteSpace($imageName)) {
    $imageName = $defaultName
}

$defaultTag = "1.0.0"
$imageTag = Read-Host "❓ Enter image tag/version (default: $defaultTag)"
if ([string]::IsNullOrWhiteSpace($imageTag)) {
    $imageTag = $defaultTag
}

# 6️⃣ Ask for Docker Hub username (namespace) — SAFE with validation
Log "ℹ️ Make sure you've created the repository on Docker Hub before pushing!"

$defaultNamespace = ""
try {
    $dockerConfig = docker info --format '{{json .AuthConfig.Username}}' 2>$null
    if ($dockerConfig -and $dockerConfig -ne '""') {
        $defaultNamespace = ($dockerConfig | ConvertFrom-Json)
    }
} catch {
    $defaultNamespace = ""
}

do {
    if ([string]::IsNullOrWhiteSpace($defaultNamespace)) {
        $defaultNamespace = Read-Host "❓ Enter your Docker Hub username (namespace)"
    } else {
        $enteredNamespace = Read-Host "❓ Enter Docker Hub username (default: $defaultNamespace)"
        if (-not [string]::IsNullOrWhiteSpace($enteredNamespace)) {
            $defaultNamespace = $enteredNamespace
        }
    }

    if ($defaultNamespace -match '[/:]') {
        Log "❌ ERROR: Docker Hub username cannot contain '/' or ':'. Please enter only your username."
        $defaultNamespace = ""
    }

} while ([string]::IsNullOrWhiteSpace($defaultNamespace))

Log "✅ Using Docker Hub username: $defaultNamespace"

# 7️⃣ Construct full image tag
$fullImageName = "${defaultNamespace}/${imageName}:${imageTag}"
Log "✅ Using full image name: $fullImageName"

# 8️⃣ Check docker login
try {
    $whoami = docker info --format '{{.AuthConfig.Username}}' 2>&1
    if (-not $whoami -or $whoami -eq "") {
        Log "⚠️ You are not logged in to Docker. Attempting login..."
        docker login
    } else {
        Log "✔️ Logged in as Docker user: $whoami"
    }
} catch {
    Log "⚠️ Docker login required."
    docker login
}

# 9️⃣ Build the Docker image
Log "🚀 Running: docker build -t $fullImageName ."
try {
    docker build -t $fullImageName .
    Log "✅ Docker image built: $fullImageName"
} catch {
    Abort "Docker build failed. Check your Dockerfile and project structure."
}

# 🔟 Optional push to Docker Hub
$pushChoice = Read-Host "❓ Do you want to push this image to Docker Hub? (y/n)"
if ($pushChoice -match '^[Yy]') {
    Log "🚀 Running: docker push $fullImageName"
    try {
        docker push $fullImageName
        Log "✅ Image pushed to Docker Hub: $fullImageName"
        Log "🌐 View it at: https://hub.docker.com/r/$defaultNamespace/$imageName"
    } catch {
        Log "❌ ERROR: Docker push failed."
        Log "Possible reasons:"
        Log "- Repository '$defaultNamespace/$imageName' does not exist on Docker Hub."
        Log "- Your user may not have permission to push."
        Log "➡️ TIP: Create the repository on Docker Hub first and ensure it's public or you have permissions."
        Log $_
    }
} else {
    Log "➡️ Skipping push to Docker Hub."
}

Log "------------------------------------------------------------"
Log "✅ All steps complete!"
Log "✅ Your project is production-ready for Docker!"
Log "------------------------------------------------------------"

Save-Log
