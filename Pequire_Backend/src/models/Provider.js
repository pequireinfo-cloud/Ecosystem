const mongoose = require('mongoose');

const providerSchema = new mongoose.Schema({
  fullName: { 
    type: String, 
    required: [true, 'Full name is required'],
    trim: true 
  },
  email: { 
    type: String, 
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true
  },
  phoneNumber: { 
    type: String, 
    required: [true, 'Phone number is required'], 
    unique: true,
    index: true 
  },
  serviceType: { 
    type: String, 
    required: true,
    // Flexible enum allowing current values plus growth
    enum: ['Carpentry', 'Plumbing', 'Electrical', 'Laundry', 'Cleaning', 'AC Repair', 'Painting'] 
  },
  expertise: [{ type: String }],
  experienceYears: { type: Number, default: 0 },
  status: { 
    type: String, 
    enum: ['Online', 'Offline', 'Busy', 'Blocked'], 
    default: 'Offline' 
  },
  kycStatus: { 
    type: String, 
    enum: ['Pending', 'Verified', 'Rejected', 'In Review'], 
    default: 'Pending' 
  },
  rating: { type: Number, default: 5.0 },
  reviewCount: { type: Number, default: 0 },
  currentStreak: { type: Number, default: 0 },
  highestStreak: { type: Number, default: 0 },
  rewardPoints: { type: Number, default: 0 },
  totalJobsCompleted: { type: Number, default: 0 },
  earnings: {
    total: { type: Number, default: 0 },
    pending: { type: Number, default: 0 }
  },
  serviceRadiusKm: { type: Number, default: 15 },
  priceLevel: { type: String, enum: ['budget', 'standard', 'premium'], default: 'standard' },
  location: {
    latitude: { type: Number },
    longitude: { type: Number },
    geo: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], index: '2dsphere' } // [longitude, latitude]
    },
    address: String
  },
  documents: {
    aadharCard: { type: String },
    panCard: { type: String },
    drivingLicense: { type: String }
  },
  rejectionReason: { type: String },
  fcmToken: { type: String },
  lastActive: Date
}, {
  timestamps: true
});

// Middleware to keep geo coordinates updated if lat/lng changes
providerSchema.pre('save', async function() {
  if (this.location && this.location.latitude !== undefined && this.location.longitude !== undefined) {
    this.location.geo.coordinates = [this.location.longitude, this.location.latitude];
  }
});

module.exports = mongoose.model('Provider', providerSchema);
