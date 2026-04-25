const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  bookingId: { 
    type: String, 
    unique: true, 
    required: true,
    index: true 
  },
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    index: true 
  },
  providerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Provider',
    index: true 
  },
  serviceType: { 
    type: String, 
    required: [true, 'Service type is required'] 
  },
  problemDescription: { 
    type: String,
    required: [true, 'Please describe the problem']
  },
  status: { 
    type: String, 
    enum: [
      'pending', 
      'searching', 
      'accepted', 
      'at_location', 
      'diagnosing', 
      'waiting_approval', 
      'working', 
      'completed', 
      'cancelled'
    ], 
    default: 'pending' 
  },
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    address: { type: String, required: true }
  },
  arrivalOtp: { type: String }, // To verify SP arrival
  completionOtp: { type: String }, // To verify job completion
  diagnosis: {
    appliance: String,
    problem: String,
    suggestedSolution: String,
    inspectionFee: { type: Number, default: 0 }
  },
  estimatedPrice: { type: Number, default: 0 },
  finalPrice: { type: Number },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'refunded'],
    default: 'pending'
  },
  rating: { type: Number, min: 1, max: 5 },
  review: { type: String },
  timeline: [{
    status: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    note: String
  }],
  matchingMetadata: {
    notifiedProviderIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Provider' }],
    searchRadiusKm: { type: Number },
    fallbacksUsed: { type: Number, default: 0 }
  }
}, {
  timestamps: true
});

// Middleware to push to timeline on status change
bookingSchema.pre('save', function(next) {
  if (this.isModified('status')) {
    this.timeline.push({
      status: this.status,
      timestamp: new Date(),
      note: `Status changed to ${this.status}`
    });
  }
  next();
});

module.exports = mongoose.model('Booking', bookingSchema);
