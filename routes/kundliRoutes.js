const express = require('express');
const router = express.Router();
const Kundli = require('../models/Kundli');

router.post('/save', async (req, res) => {
  try {
    const kundliData = req.body;
    const kundli = new Kundli(kundliData);
    await kundli.save();
    res.json({ status: 'success', data: kundli });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

router.get('/all', async (req, res) => {
  try {
    const kundlis = await Kundli.find();
    res.json({ status: 'success', data: kundlis });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

module.exports = router;
