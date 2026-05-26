const axios = require('axios');
const FormData = require('form-data');

async function testEndpoints() {
  try {
    console.log('Testing upload...');
    const form = new FormData();
    form.append('file', Buffer.from('hello'), { filename: 'test.txt', contentType: 'text/plain' });
    
    const uploadRes = await axios.post('https://api.pequire.com/api/upload', form, {
      headers: form.getHeaders(),
      validateStatus: () => true
    });
    console.log('Upload status:', uploadRes.status);
    console.log('Upload body:', uploadRes.data);

    console.log('\nTesting PUT /providers/:id/kyc...');
    const putRes = await axios.put('https://api.pequire.com/api/providers/6652e7a1b023f70b4c810000/kyc', {
      kycStatus: 'In Review'
    }, {
      validateStatus: () => true
    });
    console.log('PUT status:', putRes.status);
    console.log('PUT body:', putRes.data);

  } catch (error) {
    console.error('Error:', error.message);
  }
}

testEndpoints();
