const axios = require('axios');

async function approve(bookingId) {
  const BASE_URL = 'http://127.0.0.1:3000/api';
  try {
    const response = await axios.post(`${BASE_URL}/bookings/${bookingId}/approve-diagnosis`);
    console.log('Diagnosis Approved successfully:', response.data.status);
  } catch (err) {
    console.error('Error approving diagnosis:', err.response ? err.response.data : err.message);
  }
}

// Using the ID from the previous turn
approve('69e07fc16bdeeaba95d38bcb');
