import axios from 'axios';

const api = axios.create({
  // Use environment variable or default to localhost
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
