const { Storage } = require('@google-cloud/storage');
require('dotenv').config();
const path = require('path');

async function createBucket() {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json';
  const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });
  const bucketName = 'pequire-a5303.appspot.com';

  console.log(`Attempting to create bucket: ${bucketName}...`);
  try {
    const [bucket] = await storage.createBucket(bucketName, {
      location: 'US',
      storageClass: 'STANDARD',
    });
    console.log(`✅ Bucket ${bucket.name} created successfully!`);
    process.exit(0);
  } catch (error) {
    console.error(`❌ Failed to create bucket:`, error.message);
    process.exit(1);
  }
}

createBucket();
