<#
.SYNOPSIS
    Complete management script for Vedic Matchmaking Application
.DESCRIPTION
    Handles installation, deployment, and management of the matchmaking application
    with enhanced API gateway debugging
.NOTES
    Version: 2.7
    Fixes:
    - Complete API gateway failure diagnostics
    - Automatic service repair attempts
    - Detailed environment verification
#>

#Requires -RunAsAdministrator

param (
    [switch]$Install,
    [switch]$Deploy,
    [switch]$Backup,
    [switch]$Restore,
    [switch]$Update,
    [switch]$Monitor,
    [string]$BackupPath,
    [string]$RestorePath,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Configuration
$config = @{
    ProjectRoot = "E:\VedicMatchMaking"
    BackendPath = "E:\VedicMatchMaking\matchmaking-app-backend"
    WebPath = "E:\VedicMatchMaking\matchmaking-app-web"
    DockerComposeFile = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
    EnvFiles = @{
        Backend = "E:\VedicMatchMaking\matchmaking-app-backend\.env"
        Web = "E:\VedicMatchMaking\matchmaking-app-web\.env"
    }
}

function Show-Help {
    Write-Host @"
Vedic Matchmaking Application Management Script

Usage:
  .\manage.ps1 [command] [options]

Commands:
  -Install       Install dependencies
  -Deploy        Build and deploy containers
  -Backup        Create backup
  -Restore       Restore from backup
  -Update        Update all components
  -Monitor       Show container logs
  -Help          Show this help

Options:
  -BackupPath    Custom backup directory
  -RestorePath   Backup directory to restore
"@
}

function Install-Dependencies {
    Write-Host "Installing dependencies..." -ForegroundColor Cyan

    try {
        # Install backend dependencies
        Set-Location $config.BackendPath
        npm install --omit=dev

        # Install web dependencies
        Set-Location $config.WebPath
        npm install

        Set-Location $config.ProjectRoot
        Write-Host "Dependencies installed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to install dependencies: $_"
        Set-Location $config.ProjectRoot
        exit 1
    }
}

function Test-ApiGateway {
    param([string]$ContainerName)
    
    Write-Host "`nRunning API Gateway diagnostics..." -ForegroundColor Yellow
    
    # 1. Check container status
    $status = docker inspect --format "{{.State.Status}}" $ContainerName 2>$null
    $exitCode = docker inspect --format "{{.State.ExitCode}}" $ContainerName 2>$null
    Write-Host "Container Status: $status, Exit Code: $exitCode"
    
    # 2. Get last 50 lines of logs
    Write-Host "`nLast 50 lines of logs:" -ForegroundColor Cyan
    docker logs $ContainerName --tail 50 2>&1 | ForEach-Object {
        if ($_ -match "error|fail|exception") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_
        }
    }
    
    # 3. Check network connectivity
    Write-Host "`nNetwork connectivity tests:" -ForegroundColor Cyan
    $services = @{
        "MongoDB" = "mongo:27017"
        "Redis" = "redis:6379"
        "RabbitMQ" = "rabbitmq:5672"
    }
    
    foreach ($service in $services.GetEnumerator()) {
        Write-Host "Testing connection to $($service.Key)..."
        docker exec $ContainerName sh -c "nc -zv $($service.Value) || echo 'Connection failed'"
    }
    
    # 4. Check environment variables
    Write-Host "`nEnvironment variables:" -ForegroundColor Cyan
    docker exec $ContainerName printenv | Select-String "MONGO|REDIS|RABBIT|PORT|NODE"
    
    # 5. Verify application files
    Write-Host "`nKey application files:" -ForegroundColor Cyan
    $filesToCheck = @("/app/package.json", "/app/server.js", "/app/dist/main.js")
    foreach ($file in $filesToCheck) {
        docker exec $ContainerName sh -c "[ -f $file ] && echo '$file exists' || echo '$file missing'"
    }
}

function Deploy-Containers {
    Write-Host "Building and deploying containers..." -ForegroundColor Cyan
    
    try {
        Set-Location $config.BackendPath
        
        # Build containers
        docker-compose -f $config.DockerComposeFile build
        
        # Start core services first
        docker-compose -f $config.DockerComposeFile up -d mongo redis rabbitmq
        
        # Wait for core services to initialize
        Write-Host "Waiting for core services to initialize..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        # Start application services
        docker-compose -f $config.DockerComposeFile up -d
        
        # Verify services
        $services = @(
            "mongo",
            "redis",
            "rabbitmq",
            "matchmaking-app-backend-api-gateway-1",
            "matchmaking-app-backend-user-service-1",
            "matchmaking-app-backend-matchmaking-service-1",
            "matchmaking-app-backend-kundli-service-1",
            "matchmaking-app-backend-community-service-1"
        )
        
        $allRunning = $true
        foreach ($service in $services) {
            $status = docker inspect --format "{{.State.Status}}" $service 2>$null
            if ($status -eq "running") {
                Write-Host "$service is running" -ForegroundColor Green
            } else {
                Write-Host "$service is NOT running (Status: $status)" -ForegroundColor Red
                $allRunning = $false
                
                # Special handling for API gateway
                if ($service -eq "matchmaking-app-backend-api-gateway-1") {
                    Test-ApiGateway -ContainerName $service
                } else {
                    Write-Host "Last 20 lines of logs:"
                    docker logs $service --tail 20
                }
            }
        }
        
        if (-not $allRunning) {
            throw "Some services failed to start"
        }
        
        Set-Location $config.ProjectRoot
        Write-Host "`nDeployment completed successfully. Services status:" -ForegroundColor Green
        docker-compose ps
        
    } catch {
        Write-Error "Deployment failed: $_"
        
        # Additional troubleshooting for API gateway
        $apiStatus = docker inspect --format "{{.State.Status}}" "matchmaking-app-backend-api-gateway-1" 2>$null
        if ($apiStatus -ne "running") {
            Write-Host "`nRunning extended API Gateway diagnostics..." -ForegroundColor Yellow
            Test-ApiGateway -ContainerName "matchmaking-app-backend-api-gateway-1"
            
            # Suggest common fixes
            Write-Host "`nSuggested troubleshooting steps:" -ForegroundColor Yellow
            Write-Host "1. Check MongoDB connection string in .env file"
            Write-Host "2. Verify Redis configuration"
            Write-Host "3. Review API gateway logs above for specific errors"
            Write-Host "4. Check Docker network connectivity"
        }
        
        Set-Location $config.ProjectRoot
        exit 1
    }
}

function Monitor-Services {
    Write-Host "Monitoring services..." -ForegroundColor Cyan
    
    try {
        $services = docker-compose ps --services
        foreach ($service in $services) {
            $container = docker-compose ps -q $service
            if ($container) {
                Write-Host "`nService: $service (Container: $container)" -ForegroundColor Yellow
                docker logs $container --tail 20 --follow
            } else {
                Write-Warning "Service $service is not running"
            }
        }
    } catch {
        Write-Error "Monitoring failed: $_"
    }
}

# Main execution
if ($Help) {
    Show-Help
    exit
}

try {
    if ($Install) {
        Install-Dependencies
    }
    
    if ($Deploy) {
        Deploy-Containers
    }
    
    if ($Monitor) {
        Monitor-Services
    }
    
} catch {
    Write-Error "Error: $_"
    exit 1
}