const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: String,
  email: String,
  password: String,
  kundliId: { type: mongoose.Schema.Types.ObjectId, ref: 'Kundli' },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
