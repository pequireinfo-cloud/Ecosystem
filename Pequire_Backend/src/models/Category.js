const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: [true, 'Category name is required'], 
    unique: true,
    trim: true,
    index: true
  },
  slug: {
    type: String,
    unique: true,
    lowercase: true
  },
  imageUrl: { type: String },
  description: { type: String },
  icon: { type: String }, // For app UI icons
  problems: [{ type: String }],
  appliances: [{ type: String }],
  priority: { type: Number, default: 0 }, // For ordering in UI
  status: { 
    type: String, 
    enum: ['Active', 'Inactive'], 
    default: 'Active' 
  }
}, {
  timestamps: true
});

// Create slug from name before saving
categorySchema.pre('save', function(next) {
  if (this.isModified('name')) {
    this.slug = this.name.toLowerCase().replace(/ /g, '-');
  }
  next();
});

module.exports = mongoose.model('Category', categorySchema);
