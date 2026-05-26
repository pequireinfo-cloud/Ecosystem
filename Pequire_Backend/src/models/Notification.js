const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  body: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['booking_created', 'booking_accepted', 'booking_arrived', 'booking_completed', 'booking_cancelled', 'payment_success', 'system', 'chat_message'],
    default: 'system',
  },
  data: {
    type: Object,
    default: {},
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null, // Populated if notification is for a user
  },
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Provider',
    default: null, // Populated if notification is for a provider
  }
}, {
  timestamps: true
});

// Indexes for faster querying
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ providerId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
