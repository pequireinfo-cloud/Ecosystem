const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
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
  role: { 
    type: String, 
    enum: ['user', 'admin'], 
    default: 'user' 
  },
  avatar: { 
    type: String,
    default: ''
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    latitude: Number,
    longitude: Number
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
  lastLogin: Date
}, {
  timestamps: true // Automatically manages createdAt and updatedAt
});

// Index for geo-spatial queries if we want to find users near a location
userSchema.index({ "address.latitude": 1, "address.longitude": 1 });

module.exports = mongoose.model('User', userSchema);
