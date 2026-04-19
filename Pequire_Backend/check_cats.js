const mongoose = require('mongoose');
const Category = require('./src/models/Category');

async function check() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  const cats = await Category.find();
  console.log(JSON.stringify(cats, null, 2));
  await mongoose.disconnect();
}

check().catch(console.error);
