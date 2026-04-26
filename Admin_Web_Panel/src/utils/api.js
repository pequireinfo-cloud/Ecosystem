import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.pequire.com/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
