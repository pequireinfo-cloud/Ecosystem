const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  userId: {
    type: String,
    unique: true
  },
  name: { 
    type: String, 
    required: [true, 'Name is required'],
    trim: true
  },
  email: { 
    type: String, 
    unique: true, 
    sparse: true, // Allows multiple null/missing emails
    lowercase: true,
    trim: true
  },
  phoneNumber: { 
    type: String, 
    required: [true, 'Phone number is required'], 
    unique: true,
    index: true // High performance lookups for login
  },
  password: { 
    type: String 
    // Used only for Admin logins. Normal users authenticate via Descope OTP.
  },
  role: { 
    type: String, 
    enum: ['user', 'admin'], 
    default: 'user' 
  },
  avatar: { 
    type: String,
    default: ''
  },
  nickname: String,
  dob: String,
  gender: {
    type: String,
    enum: ['Male', 'Female', 'Other', 'Not Specified'],
    default: 'Not Specified'
  },
  country: {
    type: String,
    default: 'India'
  },
  address: {
    street: String,
    city: String,
    state: String,
    country: String,
    zipCode: String,
    latitude: Number,
    longitude: Number
  },
  preferences: {
    pushNotifications: { type: Boolean, default: true },
    biometricAuth: { type: Boolean, default: false },
    theme: { type: String, default: 'light' },
    language: { type: String, default: 'en' }
  },
  status: { 
    type: String, 
    enum: ['active', 'inactive', 'blocked'], 
    default: 'active' 
  },
  kycStatus: { 
    type: String, 
    enum: ['not_started', 'pending', 'verified', 'rejected'], 
    default: 'not_started' 
  },
  rating: { type: Number, default: 5.0 },
  reviewCount: { type: Number, default: 0 },
  currentStreak: { type: Number, default: 0 },
  highestStreak: { type: Number, default: 0 },
  rewardPoints: { type: Number, default: 0 },
  lastActiveDate: Date,
  coupons: [{
    code: String,
    title: String,
    description: String,
    discount: String,
    expiryDate: Date,
    isUsed: { type: Boolean, default: false }
  }],
  lastLogin: Date
}, {
  timestamps: true // Automatically manages createdAt and updatedAt
});

userSchema.pre('save', async function() {
  if (this.isNew || !this.userId) {
    const randomHex = Math.floor(Math.random() * 16777215).toString(16).toUpperCase().padStart(6, '0');
    this.userId = `PEQ-U-${randomHex}`;
  }
});

// Index for geo-spatial queries if we want to find users near a location
userSchema.index({ "address.latitude": 1, "address.longitude": 1 });

module.exports = mongoose.model('User', userSchema);
