# PowerShell Script to automate the backend and Kundli generation setup

# Define variables
$projectName = "kundli-service"
$projectPath = "E:\VedicMatchMaking\matchmaking-app-backend\services\kundli"
$pythonScriptPath = "$projectPath\kundli_calculator.py"
$nodeModulesPath = "$projectPath\node_modules"

# Step 1: Create Project Directory and Initialize Node Project
Write-Host "Creating the project directory..."
New-Item -Path $projectPath -ItemType Directory -Force

Set-Location -Path $projectPath

Write-Host "Initializing Node.js project..."
npm init -y  # Initialize the project

# Step 2: Install Required Node.js Dependencies
Write-Host "Installing Node.js dependencies..."
npm install express mongoose cors nodemon dayjs axios mathjs winston joi jsonwebtoken redis

# Step 3: Install Python and Dependencies for Swiss Ephemeris
Write-Host "Installing Python dependencies..."
# Ensure that Python is installed
$pythonVersion = python --version
if ($pythonVersion -eq $null) {
    Write-Host "Python is not installed. Please install Python and rerun the script."
    exit
}

# Install Swiss Ephemeris Python package
pip install pyswisseph

# Step 4: Create Necessary Files for Backend and Kundli Calculation

Write-Host "Creating necessary files..."

# Create the main Node.js server file (app.js)
$appJsContent = @"
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");

const kundliRoutes = require("./routes/kundli");

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use("/api/kundli", kundliRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(\`Server is running on port \${PORT}\`);
});
"@
Set-Content -Path "$projectPath\app.js" -Value $appJsContent

# Create Python script for Kundli calculation (kundli_calculator.py)
$kundliCalculatorContent = @"
import swisseph as swe
import sys
import json

def calculate_kundli(birth_date, birth_time, latitude, longitude):
    jd = swe.julday(*map(int, birth_date.split('-')), float(birth_time.split(':')[0]) + float(birth_time.split(':')[1])/60)
    
    planet_positions = {}
    for planet_id in range(1, 11):
        position = swe.calc(jd, planet_id)
        planet_positions[planet_id] = position[0]

    houses = swe.houses(jd, lat=latitude, lon=longitude)
    ascendant = houses[0][0]

    moon_position = planet_positions[2]
    nakshatra = get_nakshatra(moon_position)

    return json.dumps({
        "planet_positions": planet_positions,
        "ascendant": ascendant,
        "nakshatra": nakshatra
    })

def get_nakshatra(moon_position):
    nakshatras = [
        "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashira", "Ardra", "Punarvasu",
        "Pushya", "Ashlesha", "Magha", "Purvaphalguni", "UttaraPhalguni", "Hasta", "Chitra",
        "Swati", "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purvashadha", "UttaraAshadha",
        "Shravana", "Dhanishta", "Shatabhisha", "Purvabhadrapada", "UttaraBhadrapada", "Revati"
    ]
    nakshatra_index = int(moon_position // 13.3333)
    return nakshatras[nakshatra_index]

if __name__ == "__main__":
    birth_date = sys.argv[1]
    birth_time = sys.argv[2]
    latitude = float(sys.argv[3])
    longitude = float(sys.argv[4])
    print(calculate_kundli(birth_date, birth_time, latitude, longitude))
"@
Set-Content -Path $pythonScriptPath -Value $kundliCalculatorContent

# Create routes directory
$routesDirectory = "$projectPath\routes"
New-Item -Path $routesDirectory -ItemType Directory -Force

# Create the route for Kundli generation (routes/kundli.js)
$kundliRouteContent = @"
const express = require("express");
const router = express.Router();
const { generateKundli } = require("../kundliService");

router.post("/generate", (req, res) => {
    const { birthDate, birthTime, latitude, longitude } = req.body;

    generateKundli(birthDate, birthTime, latitude, longitude, (error, kundliData) => {
        if (error) {
            return res.status(500).send({ error: "Error generating Kundli" });
        }
        res.json(kundliData);
    });
});

module.exports = router;
"@
Set-Content -Path "$routesDirectory\kundli.js" -Value $kundliRouteContent

# Step 5: Create Kundli Service to Call Python Script (kundliService.js)
$kundliServiceContent = @"
const { exec } = require("child_process");

function generateKundli(birthDate, birthTime, latitude, longitude, callback) {
    const pythonScript = "python3 kundli_calculator.py";
    const command = \`\${pythonScript} \${birthDate} \${birthTime} \${latitude} \${longitude}\`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(\`exec error: \${error}\`);
            return callback(error, null);
        }
        if (stderr) {
            console.error(\`stderr: \${stderr}\`);
            return callback(stderr, null);
        }
        callback(null, JSON.parse(stdout));
    });
}

module.exports = { generateKundli };
"@
Set-Content -Path "$projectPath\kundliService.js" -Value $kundliServiceContent

# Step 6: Display Final Instructions
Write-Host "Backend setup and Kundli calculation logic is complete."
Write-Host "1. To run the server, use 'npm run dev' or 'node app.js'."
Write-Host "2. Ensure Python and Swiss Ephemeris are correctly installed."
Write-Host "3. Check the routes at /api/kundli/generate for Kundli generation API."

Write-Host "You can now start using the backend to generate Kundlis."

