const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');
const Provider = require('./src/models/Provider');
const User = require('./src/models/User');
const bookingService = require('./src/services/bookingService');

async function testRatingSystem() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  console.log('Connected to MongoDB');

  // Cleanup previous failed runs
  await User.deleteOne({ email: 'testuser@example.com' });
  await Provider.deleteOne({ email: 'testprovider@example.com' });
  console.log('Previous test data cleaned up');

  // 1. Create a User
  const user = new User({
    name: 'Test User',
    phoneNumber: '+91 9999999999',
    email: 'testuser@example.com',
    role: 'user'
  });
  await user.save();
  console.log('Test User Created');

  // 2. Create a Provider
  const provider = new Provider({
    fullName: 'Test Provider',
    phoneNumber: '+91 8888888888',
    email: 'testprovider@example.com',
    serviceType: 'Electrical',
    rating: 5.0,
    reviewCount: 0,
    location: {
      latitude: 28.6139,
      longitude: 77.2090,
      address: 'Test Market'
    }
  });
  await provider.save();
  console.log('Test Provider Created');

  // 3. Create Bookings
  const b1 = new Booking({
    bookingId: 'B1',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Electrical',
    problemDescription: 'Test job 1',
    status: 'completed',
    location: { latitude: 0, longitude: 0, address: 'Test' }
  });
  await b1.save();

  const b2 = new Booking({
    bookingId: 'B2',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Electrical',
    problemDescription: 'Test job 2',
    status: 'completed',
    location: { latitude: 0, longitude: 0, address: 'Test' }
  });
  await b2.save();
  console.log('Bookings Created');

  // 4. Submit Ratings
  console.log('Submitting 4-star rating for B1...');
  await bookingService.submitFeedback(b1._id, 4, 'Good work');

  let updatedProvider = await Provider.findById(provider._id);
  console.log(`Current Provider Rating: ${updatedProvider.rating} (Expected: 4.0), ReviewCount: ${updatedProvider.reviewCount}`);

  console.log('Submitting 2-star rating for B2...');
  await bookingService.submitFeedback(b2._id, 2, 'Bad work');

  updatedProvider = await Provider.findById(provider._id);
  console.log(`Current Provider Rating: ${updatedProvider.rating} (Expected: 3.0), ReviewCount: ${updatedProvider.reviewCount}`);

  // Cleanup
  await User.deleteOne({ _id: user._id });
  await Provider.deleteOne({ _id: provider._id });
  await Booking.deleteMany({ providerId: provider._id });
  
  await mongoose.disconnect();
  console.log('Disconnected');
}

testRatingSystem().catch(err => console.error(err));
