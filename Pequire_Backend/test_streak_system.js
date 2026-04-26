const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');
const Provider = require('./src/models/Provider');
const User = require('./src/models/User');
const bookingService = require('./src/services/bookingService');

async function testStreakSystem() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  console.log('Connected to MongoDB');

  // 1. Setup & Cleanup
  await User.deleteMany({ email: 'streak@example.com' });
  await Provider.deleteMany({ email: 'streaksp@example.com' });

  const user = new User({ name: 'Streak User', phoneNumber: '+91 8888888888', email: 'streak@example.com' });
  await user.save();
  const provider = new Provider({ 
    fullName: 'Streak SP', 
    phoneNumber: '+91 9999999999', 
    email: 'streaksp@example.com', 
    serviceType: 'Cleaning',
    location: { latitude: 19.0, longitude: 72.0, address: 'Mumbai' }
  });
  await provider.save();

  // 2. Test Success Flow (Streak +1)
  console.log('--- Test Success Flow ---');
  const b1 = new Booking({
    bookingId: 'B_STREAK_1',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Cleaning',
    problemDescription: 'Cleaning required',
    status: 'completed',
    paymentMethod: 'online',
    paymentStatus: 'paid',
    location: { latitude: 19.0, longitude: 72.0, address: 'Mumbai' }
  });
  await b1.save();

  console.log('User rating SP...');
  await bookingService.submitFeedback(b1._id, 5, 'Great!');
  
  console.log('SP rating User...');
  await bookingService.submitUserFeedback(b1._id, 5, 'Good customer');

  let u = await User.findById(user._id);
  let p = await Provider.findById(provider._id);
  console.log(`User Streak: ${u.currentStreak}, SP Streak: ${p.currentStreak}`);

  // 3. Test Reset Flow (Cancel -> Streak 0)
  console.log('--- Test Reset Flow ---');
  const b2 = new Booking({
    bookingId: 'B_STREAK_2',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Cleaning',
    problemDescription: 'Cleaning required 2',
    status: 'pending',
    location: { latitude: 19.0, longitude: 72.0, address: 'Mumbai' }
  });
  await b2.save();

  console.log('User cancelling booking...');
  await bookingService.cancelBooking(b2._id, 'user');

  u = await User.findById(user._id);
  console.log(`User Streak after cancel: ${u.currentStreak} (Expected 0)`);

  // 4. Test Milestone Reward
  console.log('--- Test Milestone Reward ---');
  // Cheat a bit for testing
  u.currentStreak = 4;
  await u.save();
  
  const b3 = new Booking({
    bookingId: 'B_STREAK_3',
    userId: user._id,
    providerId: provider._id,
    serviceType: 'Cleaning',
    problemDescription: 'Cleaning 3',
    status: 'completed',
    location: { latitude: 19.0, longitude: 72.0, address: 'Mumbai' }
  });
  await b3.save();

  console.log('User rating SP for 5th streak...');
  await bookingService.submitFeedback(b3._id, 5, '5th job!');
  
  u = await User.findById(user._id);
  console.log(`User Streak: ${u.currentStreak}, Reward Points: ${u.rewardPoints} (Expected 50)`);

  // Cleanup
  await User.deleteOne({ _id: user._id });
  await Provider.deleteOne({ _id: provider._id });
  await Booking.deleteMany({ userId: user._id });

  await mongoose.disconnect();
  console.log('Done');
}

testStreakSystem().catch(err => console.error(err));
