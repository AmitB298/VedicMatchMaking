const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  birthDate: String,
  birthTime: String,
  birthPlace: String,
  kundliData: Object
});

module.exports = mongoose.model('User', userSchema);
