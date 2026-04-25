const mongoose = require('mongoose');
const bookingService = require('./src/services/bookingService');
const Provider = require('./src/models/Provider');
const Booking = require('./src/models/Booking');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';

async function testExpertiseMatching() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    const testUserLocation = {
      latitude: 26.4716,
      longitude: 80.3512,
      address: 'Naveen Market Area'
    };

    console.log('--- TEST 1: Specific Problem (Leaking Tap) ---');
    const booking1 = await bookingService.createBooking({
      userId: 'user_1',
      serviceType: 'Plumbing',
      problemDescription: 'My kitchen tap has a serious leak',
      location: testUserLocation
    });
    
    await new Promise(r => setTimeout(r, 2000));
    let result1 = await Booking.findById(booking1._id).populate('matchingMetadata.notifiedProviderIds');
    console.log(`Identified Skills: [${result1.matchingMetadata.notifiedProviderIds[0]?.expertise.filter(e => e.includes('leak'))}]`);
    console.log(`Result: ${result1.matchingMetadata.notifiedProviderIds.length} specialists notified.`);

    console.log('\n--- TEST 2: Multi-Skill Problem (Fan and Switchboard) ---');
    const booking2 = await bookingService.createBooking({
      userId: 'user_2',
      serviceType: 'Electrical',
      problemDescription: 'The ceiling fan is noisy and the switchboard is burnt',
      location: testUserLocation
    });

    await new Promise(r => setTimeout(r, 2000));
    let result2 = await Booking.findById(booking2._id).populate('matchingMetadata.notifiedProviderIds');
    console.log(`Identified Specialist Expertise: ${result2.matchingMetadata.notifiedProviderIds[0]?.expertise}`);
    console.log(`Result: ${result2.matchingMetadata.notifiedProviderIds.length} specialists notified.`);

    console.log('\n--- TEST 3: Fallback (No specific skill) ---');
    const booking3 = await bookingService.createBooking({
      userId: 'user_3',
      serviceType: 'Carpentry',
      problemDescription: 'I need some general wood work help',
      location: testUserLocation
    });

    await new Promise(r => setTimeout(r, 2000));
    let result3 = await Booking.findById(booking3._id).populate('matchingMetadata.notifiedProviderIds');
    console.log(`Fallbacks Used: ${result3.matchingMetadata.fallbacksUsed} (Expected: >0)`);
    console.log(`Result: ${result3.matchingMetadata.notifiedProviderIds.length} generalists notified.`);

    await mongoose.disconnect();
    process.exit(0);
  } catch (error) {
    console.error('Expertise Match Test Failed:', error);
    process.exit(1);
  }
}

testExpertiseMatching();
