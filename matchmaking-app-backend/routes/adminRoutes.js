// adminRoutes.js
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');

router.post('/ban/:id', auth, adminController.banUser);
router.get('/stats', auth, adminController.getStats);

module.exports = router;
