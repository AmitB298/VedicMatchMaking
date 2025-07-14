const User = require('../models/User');
const axios = require('axios');

exports.generateKundli = async (req, res) => {
  try {
    const { birthDate, birthTime, birthPlace } = req.body;
    const response = await axios.post(process.env.KUNDLI_SERVICE_URL, { birthDate, birthTime, birthPlace });
    await User.findByIdAndUpdate(req.user.id, {
      birthDate,
      birthTime,
      birthPlace,
      kundliData: response.data
    });
    res.json({ kundli: response.data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
