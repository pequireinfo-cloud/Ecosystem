import axios from 'axios';

const api = axios.create({
  // Use environment variable or default to production url
  baseURL: import.meta.env.VITE_API_BASE_URL || 'https://api.pequire.com/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
