const mongoose = require('mongoose'); 
const Provider = require('./src/models/Provider'); 
require('dotenv').config(); 
mongoose.connect(process.env.MONGODB_URI).then(async () => { 
  try { 
    await Provider.create({ 
      phoneNumber: '+919999999999', 
      fullName: 'New Partner', 
      serviceType: 'Carpentry', 
      status: 'Offline', 
      location: { geo: { type: 'Point', coordinates: [0, 0] } } 
    }); 
    console.log('Provider created successfully!'); 
  } catch (e) { 
    console.error('Error creating provider:', e); 
  } 
  mongoose.disconnect(); 
});
