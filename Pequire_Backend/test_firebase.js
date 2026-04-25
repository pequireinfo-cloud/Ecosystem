const admin = require('firebase-admin');
require('dotenv').config();
const path = require('path');

async function testInit() {
  try {
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    console.log('Testing with path:', serviceAccountPath);
    
    admin.initializeApp({
      credential: admin.credential.cert(path.resolve(serviceAccountPath))
    });
    
    console.log('✅ Firebase Admin initialized successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Firebase Admin Initialization Failed:');
    console.error(error.message);
    process.exit(1);
  }
}

testInit();
