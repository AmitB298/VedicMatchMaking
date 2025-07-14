const express = require('express');
const router = express.Router();
const kundliController = require('../controllers/kundliController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/generate-kundli', authMiddleware, kundliController.generateKundli);

module.exports = router;
