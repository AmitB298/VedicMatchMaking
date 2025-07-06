const mongoose = require('mongoose');

const KundliSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  name: String,
  birth_date: Date,
  birth_time: String,
  birth_place: String,
  latitude: Number,
  longitude: Number,
  guna_score: Number,
  guna_breakdown: Object,
  dasha_koota_score: Number,
  kaal_sarp_dosha: String,
  mangal_dosha: String,
  navamsa: String,
  verdict: String,
}, { timestamps: true });

module.exports = mongoose.model('Kundli', KundliSchema);
