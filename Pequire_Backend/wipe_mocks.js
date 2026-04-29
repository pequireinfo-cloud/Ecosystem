const mongoose = require('mongoose');
require('dotenv').config();

async function wipeMockData() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire');
    console.log('Connected to MongoDB');

    const User = require('./src/models/User');
    const Provider = require('./src/models/Provider');
    const Booking = require('./src/models/Booking');

    // 1. Delete all providers (since they were all seeded mocks)
    console.log('Deleting all providers...');
    const providerResult = await Provider.deleteMany({});
    console.log(`Deleted ${providerResult.deletedCount} providers.`);

    // 2. Delete all bookings
    console.log('Deleting all bookings...');
    const bookingResult = await Booking.deleteMany({});
    console.log(`Deleted ${bookingResult.deletedCount} bookings.`);

    // 3. Delete all users EXCEPT those with role 'admin'
    console.log('Deleting all non-admin users...');
    const userResult = await User.deleteMany({ role: { $ne: 'admin' } });
    console.log(`Deleted ${userResult.deletedCount} users.`);

    console.log('✅ Database successfully purged of all mock data!');
    process.exit(0);
  } catch (error) {
    console.error('Error wiping data:', error);
    process.exit(1);
  }
}

wipeMockData();
