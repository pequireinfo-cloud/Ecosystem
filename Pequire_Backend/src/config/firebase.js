const admin = require('firebase-admin');

// IMPORTANT: The user needs to download their serviceAccountKey.json from Firebase Console
// Project Settings > Service Accounts > Generate New Private Key
// Place it in the backend folder or use environment variables.

try {
  // If running locally, you must store the service account key alongside your code.
  // const serviceAccount = require('../../serviceAccountKey.json');
  // admin.initializeApp({
  //   credential: admin.credential.cert(serviceAccount)
  // });
  
  // Alternative: Using GOOGLE_APPLICATION_CREDENTIALS in .env
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
        credential: admin.credential.applicationDefault()
    });
    console.log('Firebase Admin Initialized successfully.');
  } else {
    console.warn('WARN: GOOGLE_APPLICATION_CREDENTIALS not set in .env');
  }
} catch (error) {
  console.error('Firebase Admin Initialization Error:', error);
}

const db = admin.apps.length ? admin.firestore() : null;
const messaging = admin.apps.length ? admin.messaging() : null;

module.exports = { admin, db, messaging };
