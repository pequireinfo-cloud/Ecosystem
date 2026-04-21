const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire';

async function setupIndexes() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('providers');

    console.log('Creating 2dsphere index on location.geo...');
    await collection.createIndex({ "location.geo": '2dsphere' });
    console.log('Index created successfully.');

    await mongoose.disconnect();
    process.exit(0);
  } catch (error) {
    console.error('Index creation failed:', error);
    process.exit(1);
  }
}

setupIndexes();
