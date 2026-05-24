const mongoose = require('mongoose');
require('dotenv').config();
const Provider = require('./src/models/Provider');

async function backfill() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to DB');

    const providers = await Provider.find({ spId: { $exists: false } });
    console.log(`Found ${providers.length} providers without spId`);

    for (const provider of providers) {
      const randomHex = Math.floor(Math.random() * 16777215).toString(16).toUpperCase().padStart(6, '0');
      provider.spId = `SP-${randomHex}`;
      
      // We must avoid triggering validations if old data is invalid, so we use findOneAndUpdate
      await Provider.findOneAndUpdate({ _id: provider._id }, { spId: provider.spId });
      console.log(`Updated ${provider.fullName} with ${provider.spId}`);
    }

    console.log('Backfill complete!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

backfill();
