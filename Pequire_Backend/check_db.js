const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');

async function check() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  const recent = await Booking.find().sort({ createdAt: -1 }).limit(5);
  console.log(JSON.stringify(recent, null, 2));
  await mongoose.disconnect();
}

check().catch(console.error);
