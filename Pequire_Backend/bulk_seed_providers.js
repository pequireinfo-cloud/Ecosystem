const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const Provider = require('./src/models/Provider');

// Load environment variables
dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';
const DATA_FILE = path.join(__dirname, '..', 'scripts', 'providers.json');

async function seed() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('Connected successfully.');

    // Read the generated JSON
    console.log(`Reading data from ${DATA_FILE}...`);
    const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
    console.log(`Loaded ${data.length} records.`);

    // Clear existing providers (Optional but usually better for a fresh test)
    console.log('Clearing existing providers...');
    await Provider.deleteMany({});
    console.log('Collection cleared.');

    // Bulk Insert
    console.log('Inserting 10,000 records (this might take a few seconds)...');
    const startTime = Date.now();
    
    // We remove provider_id from the object if we want MongoDB to rely on _id, 
    // but the user requested provider_id specifically, so we keep it.
    await Provider.insertMany(data);
    
    const duration = (Date.now() - startTime) / 1000;
    console.log(`Successfully seeded ${data.length} providers in ${duration}s.`);

    process.exit(0);
  } catch (error) {
    console.error('Seeding failed:', error);
    process.exit(1);
  }
}

seed();
