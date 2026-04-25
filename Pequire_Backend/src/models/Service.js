const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
  providerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Provider', 
    required: true,
    index: true 
  },
  categoryId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Category', 
    required: true 
  },
  name: { 
    type: String, 
    required: [true, 'Service name is required'],
    trim: true 
  },
  description: { type: String },
  price: { 
    type: Number, 
    required: [true, 'Service price is required'],
    min: [0, 'Price cannot be negative'] 
  },
  discount: { 
    type: Number, 
    default: 0,
    min: [0, 'Discount cannot be negative'],
    max: [100, 'Discount cannot exceed 100%']
  },
  imageUrl: { type: String },
  coveragePoints: [{ type: String }],
  status: { 
    type: String, 
    enum: ['Active', 'Inactive'], 
    default: 'Active' 
  }
}, {
  timestamps: true
});

// Index for finding services by provider and category
serviceSchema.index({ providerId: 1, categoryId: 1 });

module.exports = mongoose.model('Service', serviceSchema);
