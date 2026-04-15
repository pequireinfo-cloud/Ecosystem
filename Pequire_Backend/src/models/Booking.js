const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  bookingId: { type: String, unique: true },
  userId: { type: String }, // User ID from Firebase/Auth
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider' },
  serviceType: { type: String, required: true },
  problemDescription: { type: String },
  status: { type: String, enum: ['pending', 'accepted', 'at_location', 'diagnosing', 'waiting_approval', 'working', 'completed', 'cancelled'], default: 'pending' },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  arrivalOtp: { type: String },
  workOtp: { type: String },
  diagnosis: {
    appliance: String,
    problem: String,
    suggestedSolution: String,
  },
  estimatedPrice: { type: Number },
  finalPrice: { type: Number },
  rating: { type: Number },
  feedback: { type: String },
  timeline: [{
    status: String,
    timestamp: { type: Date, default: Date.now }
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', bookingSchema);
