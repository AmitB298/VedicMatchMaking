$ErrorActionPreference = "Stop"

# CONFIG
$apiBase = "http://localhost:3000/api/v1/users"
$mongoUri = "mongodb://localhost:27017/vedicmatch"
$testUser = @{
    name = "E2E_SYNC_TEST_USER"
    email = "e2e_sync@example.com"
    phone = "9999999999"
    password = "test1234"
}

Write-Host "`n🚀 Starting E2E sync test..." -ForegroundColor Cyan

# 1. Insert via Backend API
Write-Host "`n📤 Sending POST request to backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $apiBase -Method POST -ContentType "application/json" -Body ($testUser | ConvertTo-Json)
    Write-Host "✅ User inserted via backend API." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to insert user via API: $_" -ForegroundColor Red
    exit 1
}

# 2. Simulate Web GET request
Write-Host "`n🌐 Simulating Web GET request..." -ForegroundColor Yellow
try {
    $webResult = Invoke-RestMethod -Uri "$apiBase?email=$($testUser.email)" -Method GET
    if ($webResult.email -eq $testUser.email) {
        Write-Host "✅ Web read verified user." -ForegroundColor Green
    } else {
        Write-Host "❌ Web read did not return expected user." -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Web GET request failed: $_" -ForegroundColor Red
}

# 3. Simulate Android GET request
Write-Host "`n📱 Simulating Android GET request..." -ForegroundColor Yellow
try {
    $androidResult = Invoke-RestMethod -Uri "$apiBase?phone=$($testUser.phone)" -Method GET
    if ($androidResult.phone -eq $testUser.phone) {
        Write-Host "✅ Android read verified user." -ForegroundColor Green
    } else {
        Write-Host "❌ Android read did not return expected user." -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Android GET request failed: $_" -ForegroundColor Red
}

# 4. Direct MongoDB verification
Write-Host "`n🧩 Verifying via MongoDB (mongosh)..." -ForegroundColor Yellow
$mongoCheck = @"
db.users.findOne({ email: '$($testUser.email)' })
"@
$mongoResult = mongosh $mongoUri --quiet --eval $mongoCheck
if ($mongoResult -match $testUser.email) {
    Write-Host "✅ MongoDB contains the inserted user." -ForegroundColor Green
} else {
    Write-Host "❌ MongoDB does not contain the user." -ForegroundColor Red
}

Write-Host "`n✅ E2E sync test complete." -ForegroundColor Cyan
