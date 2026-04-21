const mongoose = require('mongoose');
const Provider = require('./src/models/Provider');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';

async function verify() {
  try {
    await mongoose.connect(MONGODB_URI);
    
    const count = await Provider.countDocuments();
    console.log(`Total Records: ${count}`);
    
    const sample = await Provider.findOne();
    console.log('Sample Record:', JSON.stringify(sample, null, 2));
    
    // Check ranges
    const lowRating = await Provider.countDocuments({ rating: { $lt: 3.5 } });
    console.log(`Low Rated Providers (<3.5): ${lowRating}`);
    
    const nearNaveen = await Provider.countDocuments({ "location.distance_km": { $lt: 2 } });
    console.log(`Providers within 2km of Naveen Market: ${nearNaveen}`);
    
    const carpenters = await Provider.countDocuments({ serviceType: 'Carpentry' });
    console.log(`Total Carpenters: ${carpenters}`);

    const plumbing = await Provider.countDocuments({ serviceType: 'Plumbing' });
    console.log(`Total Plumbers: ${plumbing}`);

    const electrical = await Provider.countDocuments({ serviceType: 'Electrical' });
    console.log(`Total Electricians: ${electrical}`);

    const laundry = await Provider.countDocuments({ serviceType: 'Laundry' });
    console.log(`Total Laundry: ${laundry}`);

    await mongoose.disconnect();
  } catch (error) {
    console.error('Verification failed:', error);
  }
}

verify();
