# Invoke-KundliMatchTest.ps1
$uri = "http://127.0.0.1:5055/api/kundli/match"

$body = @{
    person1 = @{
        name       = "Ram"
        birth_date = "1990-01-01"
        birth_time = "12:00:00"
        latitude   = 28.6139
        longitude  = 77.2090
    }
    person2 = @{
        name       = "Sita"
        birth_date = "1992-05-10"
        birth_time = "14:30:00"
        latitude   = 19.0760
        longitude  = 72.8777
    }
} | ConvertTo-Json -Depth 5

try {
    Write-Host "📡 Sending request to $uri ..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/json"
    Write-Host "`n✅ Guna Score:" $response.guna_score
    Write-Host "🔍 Verdict:" $response.verdict
} catch {
    Write-Host "`n❌ Request failed: $($_.Exception.Message)" -ForegroundColor Red
}
