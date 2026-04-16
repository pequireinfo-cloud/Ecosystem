const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');

async function check() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  const recent = await Booking.find().sort({ createdAt: -1 }).limit(1);
  if (recent.length > 0) {
    console.log('MOST RECENT BOOKING:');
    console.log(JSON.stringify(recent[0], null, 2));
  } else {
    console.log('NO BOOKINGS FOUND');
  }
  await mongoose.disconnect();
}

check().catch(console.error);
