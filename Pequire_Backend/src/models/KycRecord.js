const mongoose = require('mongoose');

const kycRecordSchema = new mongoose.Schema({
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Provider',
    required: true,
    unique: true
  },
  fullName: {
    type: String,
    required: true
  },
  phoneNumber: {
    type: String,
    required: true
  },
  documents: {
    aadharCard: String,
    panCard: String,
    drivingLicense: String
  },
  status: {
    type: String,
    enum: ['Verified', 'Rejected'],
    required: true
  },
  rejectionReason: String,
  verifiedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('KycRecord', kycRecordSchema);
