const axios = require('axios');

async function create() {
  const BASE_URL = 'http://127.0.0.1:3000/api';
  try {
    const response = await axios.post(`${BASE_URL}/bookings`, {
      userId: 'test_user_789',
      serviceType: 'Electrical Works',
      problemDescription: 'Power Surge in Living Room',
      location: {
        latitude: 28.6139,
        longitude: 77.2090,
        address: '123, Green Park, Delhi'
      },
      estimatedPrice: 150
    });
    console.log('Booking Created:', response.data.booking._id);
  } catch (err) {
    console.error('Error creating booking:', err.response ? err.response.data : err.message);
  }
}

create();
