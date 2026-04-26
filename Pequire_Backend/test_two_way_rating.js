const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');
const Provider = require('./src/models/Provider');
const User = require('./src/models/User');
const bookingService = require('./src/services/bookingService');

async function testTwoWayRating() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  console.log('Connected to MongoDB');

  // Cleanup
  await User.deleteOne({ email: 'testcustomer@example.com' });
  await Provider.deleteOne({ email: 'testprovider@example.com' });

  // 1. Create a User
  const user = new User({
    name: 'Test Customer',
    phoneNumber: '+91 7777777777',
    email: 'testcustomer@example.com',
    role: 'user',
    rating: 5.0,
    reviewCount: 0
  });
  await user.save();
  console.log('Test User Created');

  // 2. Create a Provider
  const provider = new Provider({
    fullName: 'Test Provider',
    phoneNumber: '+91 6666666666',
    email: 'testprovider@example.com',
    serviceType: 'Plumbing',
    location: { latitude: 0, longitude: 0, address: 'Test' }
  });
  await provider.save();
  console.log('Test Provider Created');

  // 3. Create Booking
  const b1 = new Booking({
    bookingId: 'B_TWO_WAY',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Plumbing',
    problemDescription: 'Sink leaking',
    status: 'completed',
    location: { latitude: 0, longitude: 0, address: 'Test' }
  });
  await b1.save();

  // 4. SP Rates User
  console.log('SP submitting 1-star rating for User...');
  await bookingService.submitUserFeedback(b1._id, 1, 'Customer was rude and delayed payment');

  let updatedUser = await User.findById(user._id);
  console.log(`Current User Rating: ${updatedUser.rating} (Expected: 1.0), ReviewCount: ${updatedUser.reviewCount}`);

  // Cleanup
  await User.deleteOne({ _id: user._id });
  await Provider.deleteOne({ _id: provider._id });
  await Booking.deleteOne({ _id: b1._id });
  
  await mongoose.disconnect();
  console.log('Disconnected');
}

testTwoWayRating().catch(err => console.error(err));
