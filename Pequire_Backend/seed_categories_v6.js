const mongoose = require('mongoose');

require('dotenv').config();
const Category = require('./src/models/Category');

async function seedCategories() {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';
    await mongoose.connect(mongoURI);
    console.log('Connected to MongoDB for seeding:', mongoURI.includes('mongodb+srv') ? 'Atlas Cluster' : 'Localhost');

    // Clear existing categories
    await Category.deleteMany({});
    console.log('Cleared existing categories');

    const categories = [
      {
        name: 'Plumbing Services',
        description: 'Quality plumbing services for pipes, leaks, and more.',
        problems: ['Leakage', 'Pipe Blockage', 'Installation', 'Tap Repair', 'Water Heater', 'Other'],
        appliances: ['Kitchen Sink', 'Wash Basin', 'Toilet', 'Shower', 'Bathtub', 'Water Tank', 'Other'],
        status: 'Active'
      },
      {
        name: 'Electrical Works',
        description: 'Expert electrical work including wiring, switches, and fixes.',
        problems: ['Short Circuit', 'Wiring Issue', 'Installation', 'Fan Repair', 'Switchboard', 'Other'],
        appliances: ['AC (Air Conditioner)', 'Refrigerator', 'Washing Machine', 'Ceiling Fan', 'Main Panel/Meter', 'Switchboard', 'Other'],
        status: 'Active'
      },
      {
        name: 'Laundry & Dry Clean',
        description: 'Complete laundry and dry cleaning with pickup and delivery.',
        problems: ['Stain Removal', 'Ironing', 'Dry Cleaning', 'General Wash', 'Other'],
        appliances: ['Shirts/T-shirts', 'Trousers/Jeans', 'Bedlinens', 'Suits', 'Sarees', 'Other'],
        status: 'Active'
      },
      {
        name: 'Carpentry',
        description: 'Skilled carpentry for furniture, doors, and woodwork.',
        problems: ['Furniture Repair', 'Woodworking', 'Door Lock Fix', 'Installation', 'Cabinet Fix', 'Other'],
        appliances: ['Bed', 'Wardrobe', 'Dining Table', 'Chair', 'Door', 'Window', 'Cabinet', 'Other'],
        status: 'Active'
      }
    ];

    // Create categories individually to trigger pre-save slug generation hook
    for (const cat of categories) {
      await Category.create(cat);
    }
    console.log('Successfully seeded 4 categories');

    process.exit();
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
}

seedCategories();
