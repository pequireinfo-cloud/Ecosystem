const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  avatar: { type: String },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String
  },
  status: { type: String, enum: ['active', 'inactive', 'blocked'], default: 'active' },
  kycStatus: { type: String, enum: ['not_started', 'pending', 'verified', 'rejected'], default: 'not_started' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);
