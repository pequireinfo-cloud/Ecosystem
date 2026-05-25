const mongoose = require('mongoose');
require('dotenv').config();
const Provider = require('./src/models/Provider');

async function repair() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to DB for repair');

    const providers = await Provider.find();
    let updatedCount = 0;

    for (const provider of providers) {
      let needsSave = false;

      // 1. Fix Phone Numbers
      if (provider.phoneNumber && provider.phoneNumber.startsWith('U3')) {
        // Generate a random valid 10-digit Indian phone number
        provider.phoneNumber = '+91' + Math.floor(6000000000 + Math.random() * 3999999999).toString();
        needsSave = true;
      }

      // 2. Fix Location Coordinates (Inject New Delhi coordinates for matching)
      if (!provider.location || provider.location.latitude === undefined || provider.location.longitude === undefined || !provider.location.geo || !provider.location.geo.coordinates || provider.location.geo.coordinates.length === 0) {
        provider.location = provider.location || {};
        provider.location.latitude = 28.6139;
        provider.location.longitude = 77.2090;
        provider.location.geo = {
          type: 'Point',
          coordinates: [77.2090, 28.6139] // [lng, lat]
        };
        needsSave = true;
      }

      if (needsSave) {
        await Provider.findOneAndUpdate(
          { _id: provider._id },
          { 
            phoneNumber: provider.phoneNumber,
            location: provider.location
          }
        );
        console.log(`Repaired ${provider.fullName} - Phone: ${provider.phoneNumber}, Coordinates set to New Delhi`);
        updatedCount++;
      }
    }

    console.log(`Repair complete! Updated ${updatedCount} providers.`);
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

repair();
