const mongoose = require('mongoose');
require('dotenv').config();

async function fixIndexes() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire');
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;

    console.log('Fixing Users collection...');
    const users = db.collection('users');
    try {
      await users.dropIndex('email_1');
    } catch (e) {}
    await users.createIndex({ email: 1 }, { unique: true, sparse: true });

    console.log('Fixing Providers collection...');
    const providers = db.collection('providers');
    try {
      await providers.dropIndex('email_1');
    } catch (e) {}
    await providers.createIndex({ email: 1 }, { unique: true, sparse: true });
    
    console.log('✅ All indexes recreated successfully with sparse: true');

    process.exit(0);
  } catch (error) {
    console.error('Error fixing indexes:', error);
    process.exit(1);
  }
}

fixIndexes();
