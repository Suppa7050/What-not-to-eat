const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    unique: true,
    required: true,
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true,
  },
  password: {
    type: String,
    required: true,
  },
  age: {
    type: Number,
  },
  height: {
    type: Number,
  },
  weight: {
    type: Number,
  },
  hasDiabetes: {
    type: Boolean,
    default: false,
  },
  additionalNotes: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('User', userSchema);
