require('dotenv').config();
const mongoose = require('mongoose');
const Provider = require('./src/models/Provider');

async function repairGeo() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://admin:LdO4fM0sO9aB2Y@pequire-cluster.mongodb.net/pequire?retryWrites=true&w=majority');
    console.log('Connected.');

    const providers = await Provider.find({});
    let updatedCount = 0;

    for (const provider of providers) {
      if (provider.location && provider.location.latitude && provider.location.longitude) {
        // If they have coordinates but no valid geo object, or we just want to force a refresh
        if (!provider.location.geo || !provider.location.geo.coordinates || provider.location.geo.coordinates.length < 2) {
          provider.location.geo = {
            type: 'Point',
            coordinates: [provider.location.longitude, provider.location.latitude]
          };
          await provider.save();
          console.log(`Fixed geo for provider: ${provider.fullName} (${provider._id})`);
          updatedCount++;
        }
      }
    }

    console.log(`\nRepair complete. Fixed ${updatedCount} providers.`);
    process.exit(0);
  } catch (err) {
    console.error('Error repairing DB:', err);
    process.exit(1);
  }
}

repairGeo();
