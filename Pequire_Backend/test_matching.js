const mongoose = require('mongoose');
const bookingService = require('./src/services/bookingService');
const Provider = require('./src/models/Provider');
const Booking = require('./src/models/Booking');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';

async function testMatching() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // 1. Create a dummy user location (near Naveen Market)
    const testLocation = {
      latitude: 26.4716,
      longitude: 80.3512,
      address: 'Naveen Market Area'
    };

    console.log('Simulating Booking Request for Electrical Service...');
    const bookingData = {
      userId: 'test_user_123',
      serviceType: 'Electrical',
      problemDescription: 'Fan not working, need urgent repair',
      location: testLocation,
      estimatedPrice: 500
    };

    // 2. Trigger Matching
    const booking = await bookingService.createBooking(bookingData);
    console.log(`Booking Created: ${booking.bookingId}`);

    // Wait a bit for the async matching to complete (simulate delay)
    console.log('Waiting for matching engine results...');
    await new Promise(resolve => setTimeout(resolve, 3000));

    // 3. Verify Results
    const updatedBooking = await Booking.findById(booking._id).populate('matchingMetadata.notifiedProviderIds');
    
    if (updatedBooking.matchingMetadata) {
      console.log('--- Matching Results ---');
      console.log(`Search Radius: ${updatedBooking.matchingMetadata.searchRadiusKm}km`);
      console.log(`Fallbacks Used: ${updatedBooking.matchingMetadata.fallbacksUsed}`);
      console.log(`Providers Notified: ${updatedBooking.matchingMetadata.notifiedProviderIds.length}`);

      updatedBooking.matchingMetadata.notifiedProviderIds.forEach((p, i) => {
        const score = updatedBooking.matchingMetadata.matchingScores[i].score;
        console.log(`[Rank #${i+1}] ${p.fullName} | Score: ${score.toFixed(4)} | Rating: ${p.rating} | Resp Time: ${p.avgResponseSeconds}s`);
      });
    } else {
      console.log('No matching metadata found. Check filters or categories.');
    }

    await mongoose.disconnect();
    process.exit(0);
  } catch (error) {
    console.error('Test failed:', error);
    process.exit(1);
  }
}

testMatching();
