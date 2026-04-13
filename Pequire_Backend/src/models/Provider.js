const mongoose = require('mongoose');

const providerSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  serviceType: { type: String, required: true },
  status: { type: String, enum: ['Online', 'Offline', 'On Job', 'Blocked'], default: 'Offline' },
  kycStatus: { type: String, enum: ['Pending', 'Verified', 'Rejected', 'In Review'], default: 'Pending' },
  rating: { type: Number, default: 0.0 },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  fcmToken: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Provider', providerSchema);
