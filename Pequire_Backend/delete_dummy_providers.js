const mongoose = require('mongoose');
const Provider = require('./src/models/Provider');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('Error: MONGODB_URI is not defined in the environment variables.');
  process.exit(1);
}

async function run() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Successfully connected to MongoDB.');

    // Find all dummy providers
    const dummyProviders = await Provider.find({
      $or: [
        { fullName: 'New Partner' },
        { phoneNumber: 'U3CzuaKrl82PDWNBliOUSh5FF7Sp' }
      ]
    });

    console.log(`Found ${dummyProviders.length} dummy provider records:`);
    dummyProviders.forEach(p => {
      console.log(`- ID: ${p._id}, Name: ${p.fullName}, Phone/UID: ${p.phoneNumber}`);
    });

    if (dummyProviders.length > 0) {
      const deleteResult = await Provider.deleteMany({
        _id: { $in: dummyProviders.map(p => p._id) }
      });
      console.log(`Successfully deleted ${deleteResult.deletedCount} dummy provider records.`);
    } else {
      console.log('No dummy provider records found to delete.');
    }

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  } catch (err) {
    console.error('An error occurred:', err);
    process.exit(1);
  }
}

run();
