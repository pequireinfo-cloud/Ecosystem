const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  bookingId: { type: String, unique: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider' },
  serviceType: { type: String, required: true },
  problemDescription: { type: String },
  status: { type: String, enum: ['pending', 'accepted', 'ongoing', 'completed', 'cancelled'], default: 'pending' },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  price: { type: Number },
  timeline: [{
    status: String,
    timestamp: { type: Date, default: Date.now }
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', bookingSchema);
