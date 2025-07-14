const express = require('express');
const router = express.Router();
const familyController = require('../controllers/familyController');

// Register
router.post('/register', familyController.registerFamily);

// Send OTP
router.post('/sendOtp', familyController.sendOtp);

// Verify OTP
router.post('/verifyOtp', familyController.verifyOtp);

// Login
router.post('/login', familyController.loginFamily);

module.exports = router;
