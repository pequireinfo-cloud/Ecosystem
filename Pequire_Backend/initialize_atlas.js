require('dotenv').config();
const mongoose = require('mongoose');
const Category = require('./src/models/Category');
const User = require('./src/models/User');
const Provider = require('./src/models/Provider');
const Booking = require('./src/models/Booking');
const Service = require('./src/models/Service');
const bcrypt = require('bcryptjs');

async function initializeAllCollections() {
  try {
    const mongoURI = process.env.MONGODB_URI;
    if (!mongoURI) {
      console.error('Error: MONGODB_URI is not defined in .env');
      process.exit(1);
    }

    console.log('Connecting to Atlas Cluster...');
    await mongoose.connect(mongoURI);
    console.log('Successfully connected!');

    // 1. Seed Categories
    console.log('\n--- Seeding Categories ---');
    await Category.deleteMany({});
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
    await Category.insertMany(categories);
    console.log('Category collection initialized (4 items).');

    // 2. Seed Admin User
    console.log('\n--- Seeding Admin User ---');
    const adminEmail = 'admin@pequire.com';
    await User.deleteOne({ email: adminEmail });
    const hashedPassword = await bcrypt.hash('admin123', 10);
    const admin = new User({
      name: 'Anurag Admin',
      email: adminEmail,
      password: hashedPassword,
      phoneNumber: '+91 0000000000',
      role: 'admin',
      profilePicture: 'https://i.pravatar.cc/150?img=12'
    });
    await admin.save();
    console.log('User collection initialized (Admin seeded).');

    // 3. Seed Mock Provider
    console.log('\n--- Seeding Service Provider ---');
    const providerPhone = '+91 9876543210';
    await Provider.deleteOne({ phoneNumber: providerPhone });
    const mockProvider = new Provider({
      fullName: 'Rahul Sharma',
      email: 'rahul.sharma@pequire.com',
      phoneNumber: providerPhone,
      serviceType: 'Plumbing',
      expertise: ['Leakage', 'Tap Repair', 'Water Heater'],
      experienceYears: 5,
      status: 'Online',
      kycStatus: 'Verified',
      rating: 4.8,
      location: {
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'Connaught Place, New Delhi, Delhi'
      }
    });
    await mockProvider.save();
    console.log('Provider collection initialized (1 Provider seeded).');

    // 4. Seed Services Offered
    console.log('\n--- Seeding Services ---');
    await Service.deleteMany({});
    const plumbingCategory = await Category.findOne({ name: 'Plumbing Services' });
    const mockService = new Service({
      providerId: mockProvider._id,
      categoryId: plumbingCategory._id,
      name: 'Tap Installation & Leak Fix',
      description: 'Professional fix for running taps and pipe leakages.',
      price: 299,
      discount: 10,
      coveragePoints: ['Materials Included', '30-Day Warranty'],
      status: 'Active'
    });
    await mockService.save();
    console.log('Service collection initialized (1 Service seeded).');

    // 5. Initialize Bookings Collection (Create a temp booking and delete it, leaving the empty collection)
    console.log('\n--- Initializing Bookings Collection ---');
    const tempBooking = new Booking({
      bookingId: 'TEMP-INITIALIZATION',
      userId: admin._id, // temporarily link to admin
      serviceType: 'Plumbing',
      problemDescription: 'Database Initialization',
      status: 'pending',
      location: {
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'Connaught Place'
      }
    });
    await tempBooking.save();
    await Booking.deleteOne({ bookingId: 'TEMP-INITIALIZATION' });
    console.log('Booking collection initialized (Successfully verified schema & left collection active).');

    console.log('\n=========================================');
    console.log('Initialization Complete! All collections are now visible on MongoDB Atlas!');
    console.log('=========================================');
    process.exit(0);
  } catch (error) {
    console.error('Initialization failed:', error);
    process.exit(1);
  }
}

initializeAllCollections();
