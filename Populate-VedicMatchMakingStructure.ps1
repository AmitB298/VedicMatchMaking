# Updated sections for Populate-VedicMatchMakingStructure.ps1
# Add to the existing script from the previous response

# Updated $structure
$structure = @{
    "matchmaking-app-web" = @{
        "public" = @(
            "index.html",
            "firebase-messaging-sw.js",
            "assets/icon.png",
            "assets/placeholder.svg"
        )
        "src" = @{
            "screens" = @(
                "OnboardingScreen.tsx",
                "LoginScreen.tsx",
                "RegisterScreen.tsx",
                "HomeScreen.tsx",
                "ProfileScreen.tsx",
                "MatchScreen.tsx",
                "ChatScreen.tsx",
                "SettingsScreen.tsx",
                "PhotoFeedbackScreen.tsx",
                "AdminPanelScreen.tsx",  # Added
                "__tests__/OnboardingScreen.test.tsx",
                "__tests__/LoginScreen.test.tsx",
                "__tests__/RegisterScreen.test.tsx",
                "__tests__/HomeScreen.test.tsx",
                "__tests__/ProfileScreen.test.tsx",
                "__tests__/MatchScreen.test.tsx",
                "__tests__/ChatScreen.test.tsx",
                "__tests__/SettingsScreen.test.tsx",
                "__tests__/PhotoFeedbackScreen.test.tsx",
                "__tests__/AdminPanelScreen.test.tsx"  # Added
            )
            "services" = @("userService.ts")
            "styles" = @("global.css")
            "" = @("App.tsx", "index.tsx", "firebase.js", "i18n.js")
        }
        "" = @("package.json", "tailwind.config.js")
    }
    "matchmaking-app-android" = @{
        "app/src/main" = @{
            "java/com/matchmaking/app/ui/screens" = @(
                "OnboardingScreen.kt",
                "LoginScreen.kt",
                "RegisterScreen.kt",
                "HomeScreen.kt",
                "ProfileScreen.kt",
                "MatchScreen.kt",
                "ChatScreen.kt",
                "SettingsScreen.kt",
                "PhotoFeedbackScreen.kt",
                "__tests__/OnboardingScreenTest.kt",
                "__tests__/LoginScreenTest.kt",
                "__tests__/RegisterScreenTest.kt",
                "__tests__/HomeScreenTest.kt",
                "__tests__/ProfileScreenTest.kt",
                "__tests__/MatchScreenTest.kt",
                "__tests__/ChatScreenTest.kt",
                "__tests__/SettingsScreenTest.kt",
                "__tests__/PhotoFeedbackScreenTest.kt"
            )
            "java/com/matchmaking/app/viewmodel" = @(
                "MatchViewModel.kt",
                "ProfileViewModel.kt",
                "ChatViewModel.kt",
                "SettingsViewModel.kt",
                "PhotoFeedbackViewModel.kt"
            )
            "java/com/matchmaking/app/core/network" = @("UserApi.kt")
            "java/com/matchmaking/app/services" = @("MessagingService.kt")
            "java/com/matchmaking/app/ui/theme" = @("Theme.kt", "colors.xml", "themes.xml")
            "java/com/matchmaking/app" = @("MainActivity.kt")
            "res/drawable" = @("ic_notification.xml", "placeholder.png")
            "res/values" = @("strings.xml", "colors.xml")
            "res/values-hi" = @("strings.xml")
            "" = @("AndroidManifest.xml")
        }
        "app" = @("build.gradle", "google-services.json")
        "" = @("build.gradle", "settings.gradle")
    }
    "matchmaking-app-backend" = @{
        "controllers" = @(
            "userController.js",
            "matchController.js",
            "casteController.js",
            "chatController.js",
            "notificationService.js",
            "adminController.js"  # Added
        )
        "models" = @("User.js", "Caste.js", "Chat.js")
        "routes" = @(
            "userRoutes.js",
            "matchRoutes.js",
            "casteRoutes.js",
            "chatRoutes.js",
            "notificationRoutes.js",
            "adminRoutes.js"  # Added
        )
        "services/verification" = @(
            "photo_verifier.py",
            "uploads",
            "models",
            "Dockerfile"
        )
        "services/kundli" = @(
            "kundli_service.py",  # Added
            "Dockerfile",  # Added
            "requirements.txt",  # Added
            "swiss_ephe"  # Added
        )
        "lib" = @("vedicID.js", "logger.js")
        "middleware" = @("auth.js")
        "Uploads" = @()
        "backups" = @()
        "tests" = @("kundli_service_test.py", "verification_test.py", "test_image.jpg")  # Added
        "" = @(
            "socket.js",
            "server.js",
            "docker-compose.yml",
            "docker-compose.yml.bak",
            "nginx.conf",
            "prometheus.yml",
            "serviceAccountKey.json",
            ".env",
            "package.json"
        )
    }
    "vedicmatchweb" = @(
        "index.html",
        "about.html",
        "contact.html",
        "services.html",
        "styles.css",
        "script.js",
        "readme.md"
    )
    "mobile" = @("readme.md", "mobile-config.json")
    "Docker" = @("Dockerfile", "docker-compose.yml")
    "" = @("Fix-DockerComposeYaml.ps1")
}

# Updated $fileContents (add missing entries)
$fileContents = @{
    # ... (keep all existing entries from previous script)
    "matchmaking-app-web/src/screens/AdminPanelScreen.tsx" = @'
// AdminPanelScreen.tsx
import React from 'react';

const AdminPanelScreen: React.FC = () => {
    return (
        <div>
            <h1>Admin Panel</h1>
            <p>Manage users, view stats, and configure settings.</p>
        </div>
    );
};

export default AdminPanelScreen;
'@
    "matchmaking-app-web/src/screens/__tests__/AdminPanelScreen.test.tsx" = @'
// AdminPanelScreen.test.tsx
import { render, screen } from '@testing-library/react';
import AdminPanelScreen from '../AdminPanelScreen';

test('renders admin panel', () => {
    render(<AdminPanelScreen />);
    expect(screen.getByText('Admin Panel')).toBeInTheDocument();
});
'@
    "matchmaking-app-backend/services/kundli/kundli_service.py" = @'
# kundli_service.py
import swisseph as swe
from datetime import datetime
import json

class KundliService:
    def __init__(self, ephe_path="swiss_ephe"):
        swe.set_ephe_path(ephe_path)

    def generate_kundli(self, birth_date, birth_time, latitude, longitude):
        dt = datetime.strptime(f"{birth_date} {birth_time}", "%Y-%m-%d %H:%M:%S")
        jd = swe.julday(dt.year, dt.month, dt.day, dt.hour + dt.minute / 60.0)
        planets = {}
        for i in range(swe.SUN, swe.PLUTO + 1):
            pos = swe.calc_ut(jd, i)[0]
            planets[swe.get_planet_name(i)] = pos
        asc = swe.houses(jd, latitude, longitude, b'P')[1][0]
        return {
            "planets": planets,
            "ascendant": asc,
            "birth_details": {
                "date": birth_date,
                "time": birth_time,
                "latitude": latitude,
                "longitude": longitude
            }
        }

    def match_kundli(self, kundli1, kundli2):
        return {"compatibility_score": 0.8}
'@
    "matchmaking-app-backend/services/kundli/Dockerfile" = @'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "kundli_service.py"]
'@
    "matchmaking-app-backend/services/kundli/requirements.txt" = @'
pyswisseph==2.10.3
'@
    "matchmaking-app-backend/tests/kundli_service_test.py" = @'
# kundli_service_test.py
import unittest
from kundli_service import KundliService

class KundliServiceTest(unittest.TestCase):
    def setUp(self):
        self.service = KundliService()

    def test_generate_kundli(self):
        kundli = self.service.generate_kundli("1990-01-01", "12:00:00", 28.6139, 77.2090)
        self.assertIn("planets", kundli)
        self.assertIn("Sun", kundli["planets"])
        self.assertIn("ascendant", kundli)

if __name__ == '__main__':
    unittest.main()
'@
    "matchmaking-app-backend/tests/verification_test.py" = @'
# verification_test.py
import unittest
import requests
import os

class VerificationServiceTest(unittest.TestCase):
    BASE_URL = 'http://localhost:5000'

    def test_verify_photo(self):
        with open('test_image.jpg', 'rb') as photo:
            response = requests.post(f'{self.BASE_URL}/verify', files={'photo': photo})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('photo', data)
        self.assertTrue(data['photo']['verified'])

    def test_verify_no_photo(self):
        response = requests.post(f'{self.BASE_URL}/verify')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main()
'@
    "matchmaking-app-backend/tests/test_image.jpg" = "# Placeholder for test_image.jpg (binary file)"
    "matchmaking-app-backend/controllers/adminController.js" = @'
const User = require('../models/User');

exports.banUser = async (req, res) => {
    try {
        const userId = req.params.id;
        await User.updateOne({ _id: userId }, { status: 'banned' });
        res.status(200).json({ message: 'User banned' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getStats = async (req, res) => {
    try {
        const stats = await User.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]);
        res.status(200).json(stats);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
'@
    "matchmaking-app-backend/routes/adminRoutes.js" = @'
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');

router.post('/ban/:id', auth, adminController.banUser);
router.get('/stats', auth, adminController.getStats);

module.exports = router;
'@
}