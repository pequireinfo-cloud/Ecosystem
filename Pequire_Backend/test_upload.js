const { admin } = require('./src/config/firebase');

async function testUpload() {
  try {
    const bucket = admin.storage().bucket();
    const file = bucket.file('test-upload.txt');
    await file.save('Hello Firebase Storage!', {
      metadata: { contentType: 'text/plain' },
      public: true
    });
    console.log('Upload successful! Public URL:');
    console.log(`https://storage.googleapis.com/${bucket.name}/test-upload.txt`);
    process.exit(0);
  } catch (error) {
    console.error('Upload Error:', error.message);
    process.exit(1);
  }
}

setTimeout(testUpload, 1000);
