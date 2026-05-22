const mongoose = require('mongoose');
const Provider = require('./src/models/Provider');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI;

async function run() {
  try {
    await mongoose.connect(MONGODB_URI);
    const providers = await Provider.find({});
    console.log(JSON.stringify(providers, null, 2));
    await mongoose.disconnect();
  } catch (err) {
    console.error(err);
  }
}
run();
