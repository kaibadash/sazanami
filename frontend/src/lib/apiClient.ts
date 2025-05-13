import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:8888/api',
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

export default apiClient; 