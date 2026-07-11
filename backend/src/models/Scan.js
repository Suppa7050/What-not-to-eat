const mongoose = require('mongoose');

const scanSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  productName: {
    type: String,
    required: true,
  },
  overallHealthScore: {
    type: Number,
    required: true,
  },
  overallIndicator: {
    type: String,
    enum: ['GREEN', 'YELLOW', 'RED'],
    required: true,
  },
  summary: {
    type: String,
  },
  analysisJson: {
    type: Object,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Scan', scanSchema);
