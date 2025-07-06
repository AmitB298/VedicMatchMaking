const mongoose = require('mongoose');

const MatchSchema = new mongoose.Schema({
  person1: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  person2: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  result: Object,
}, { timestamps: true });

module.exports = mongoose.model('Match', MatchSchema);
