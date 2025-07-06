const express = require('express');
const router = express.Router();
const Kundli = require('../models/Kundli');

router.post('/save', async (req, res) => {
    try {
        const kundli = new Kundli(req.body);
        await kundli.save();
        res.json({ status: 'success', data: kundli });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: 'error', message: err.message });
    }
});

router.get('/all', async (req, res) => {
    try {
        const kundlis = await Kundli.find();
        res.json({ status: 'success', data: kundlis });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
});

module.exports = router;
