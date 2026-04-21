const mongoose = require('mongoose');

const providerSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  serviceType: { type: String, required: true, enum: ['Carpentry', 'Plumbing', 'Electrical', 'Laundry'] },
  expertise: [{ type: String }],
  experienceYears: { type: Number, default: 0 },
  status: { type: String, enum: ['Online', 'Offline', 'Busy', 'Blocked'], default: 'Offline' },
  kycStatus: { type: String, enum: ['Pending', 'Verified', 'Rejected', 'In Review'], default: 'Pending' },
  rating: { type: Number, default: 4.0 },
  totalJobsCompleted: { type: Number, default: 0 },
  acceptanceRate: { type: Number, default: 100 },
  cancellationRate: { type: Number, default: 0 },
  avgResponseSeconds: { type: Number, default: 600 },
  serviceRadiusKm: { type: Number, default: 10 },
  priceLevel: { type: String, enum: ['budget', 'standard', 'premium'], default: 'standard' },
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    geo: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], index: '2dsphere' } // [longitude, latitude]
    },
    address: String,
    distance_km: Number
  },
  languages: [{ type: String }],
  availableSlots: [{ type: String }],
  fcmToken: { type: String },
  createdAt: { type: Date, default: Date.now }
});


module.exports = mongoose.model('Provider', providerSchema);
