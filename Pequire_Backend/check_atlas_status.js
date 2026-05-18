require('dotenv').config();
const mongoose = require('mongoose');

async function auditDatabase() {
  try {
    const mongoURI = process.env.MONGODB_URI;
    if (!mongoURI) {
      console.error('\x1b[31mError: MONGODB_URI is not defined in your .env file.\x1b[0m');
      process.exit(1);
    }

    console.log('\x1b[36mConnecting to MongoDB Atlas...\x1b[0m');
    await mongoose.connect(mongoURI);
    console.log('\x1b[32m✔ MongoDB Connection Successful!\x1b[0m');

    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);

    console.log('\n\x1b[1m=== DATABASE AUDIT REPORT ===\x1b[0m');
    console.log(`Database Name: \x1b[33m${db.databaseName}\x1b[0m`);
    console.log(`Total Collections Found: \x1b[33m${collections.length}\x1b[0m\n`);

    const expectedCollections = ['categories', 'users', 'providers', 'services', 'bookings'];
    let allHealthy = true;

    for (const expected of expectedCollections) {
      if (collectionNames.includes(expected)) {
        const count = await db.collection(expected).countDocuments();
        console.log(`\x1b[32m✔ Collection [${expected}] exists! Documents: ${count}\x1b[0m`);
      } else {
        console.log(`\x1b[31m✘ Collection [${expected}] IS MISSING!\x1b[0m`);
        allHealthy = false;
      }
    }

    console.log('\n=====================================');
    if (allHealthy) {
      console.log('\x1b[32m\x1b[1mSUCCESS: All 5 core structured database collections are formed and fully active!\x1b[0m');
    } else {
      console.log('\x1b[31m\x1b[1mWARNING: Some collections are missing. Please run "node initialize_atlas.js" first.\x1b[0m');
    }
    console.log('=====================================');

    process.exit(0);
  } catch (error) {
    console.error('\n\x1b[31mAudit Failed! Connection or schema query error:\x1b[0m', error.message);
    process.exit(1);
  }
}

auditDatabase();
