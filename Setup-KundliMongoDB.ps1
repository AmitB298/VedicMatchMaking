<#
.SYNOPSIS
    Automates the setup of MongoDB schema and seed data for Kundli Matching Service
#>

param (
    [string]$MongoUri = "mongodb://localhost:27017",
    [string]$Database = "vedic_matchmaking"
)

Write-Host "🛠️  Starting MongoDB Kundli schema setup..." -ForegroundColor Cyan

# Create temporary JS file for mongosh
$mongoScript = @"
use $Database

// Create users collection and insert sample user
db.users.insertOne({
    name: "Ram Sharma",
    email: "ram@example.com",
    phone: "+91-9876543210",
    passwordHash: "bcryptHashHere",
    createdAt: new Date(),
    updatedAt: new Date()
})

// Create kundlis collection and insert sample kundli
db.kundlis.insertOne({
    userId: db.users.findOne({email: "ram@example.com"})._id,
    name: "Ram",
    birthDate: "1990-01-01",
    birthTime: "12:00:00",
    birthPlace: "Delhi",
    latitude: 28.6139,
    longitude: 77.2090,
    computedChart: {
        lagna: "Mesha",
        nakshatra: "Ashwini",
        rashi: "Aries",
        planetPositions: [
            {planet: "Sun", sign: "Sagittarius", degree: 10.5}
        ],
        mangalDosha: false,
        kaalSarpDosha: false,
        navamsaChart: {}
    },
    createdAt: new Date(),
    updatedAt: new Date()
})

// Create matches collection and insert sample match
db.matches.insertOne({
    user1Id: db.users.findOne({email: "ram@example.com"})._id,
    user2Id: db.users.findOne({email: "ram@example.com"})._id,
    kundli1Id: db.kundlis.findOne({name: "Ram"})._id,
    kundli2Id: db.kundlis.findOne({name: "Ram"})._id,
    matchScore: 27,
    dashaKootaScore: 2,
    gunaBreakdown: [
        {name: "Varna", score: 1},
        {name: "Vashya", score: 2}
    ],
    mangalDosha1: false,
    mangalDosha2: false,
    kaalSarpDosha1: false,
    kaalSarpDosha2: false,
    verdict: "Good compatibility with minor remedies.",
    createdAt: new Date()
})

// Print summaries
print("✅ Users:", db.users.find().toArray())
print("✅ Kundlis:", db.kundlis.find().toArray())
print("✅ Matches:", db.matches.find().toArray())
"@

$tempFile = New-TemporaryFile
$mongoScript | Set-Content -Path $tempFile

Write-Host "📜 Temporary MongoDB script created at: $tempFile" -ForegroundColor Yellow

# Run the script using mongosh
Write-Host "🚀 Running mongosh to set up database..." -ForegroundColor Green
& mongosh $MongoUri $tempFile

# Clean up
Remove-Item $tempFile
Write-Host "✅ MongoDB schema setup complete!" -ForegroundColor Cyan
