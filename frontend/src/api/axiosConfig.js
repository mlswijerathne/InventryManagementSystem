import axios from 'axios';

const API_BASE_URL = 'http://localhost:5001/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    const { response } = error;
    // Handle different types of errors here
    if (response?.status === 404) {
      console.error('Resource not found');
    } else if (response?.status === 500) {
      console.error('Server error');
    }
    return Promise.reject(error);
  }
);

export default apiClient;
