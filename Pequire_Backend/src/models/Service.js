const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider', required: true },
  categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  discount: { type: Number, default: 0 },
  imageUrl: { type: String },
  coveragePoints: [{ type: String }],
  status: { type: String, enum: ['Active', 'Inactive'], default: 'Active' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Service', serviceSchema);
