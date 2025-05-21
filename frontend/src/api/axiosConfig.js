import axios from 'axios';

// Configure the base URL with fallback options
const API_BASE_URL = 'http://localhost:5001/api';
const FALLBACK_URL = 'http://127.0.0.1:5001/api';

// Function to test if a URL is accessible
const testUrl = async (url) => {
  try {
    await axios.get(`${url}/categories/test-connection`, { timeout: 3000 });
    console.log(`Backend server at ${url} is accessible`);
    return true;
  } catch (error) {
    console.error(`Backend server at ${url} is not accessible:`, error.message);
    return false;
  }
};

// Create axios instance with initial configuration
const apiClient = axios.create({
  baseURL: API_BASE_URL, // Start with the default URL
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false, // Changed to false to avoid CORS issues
  timeout: 15000, // Increased from 8000 to 15000 to allow more time for report generation
});

// This function will be called when a network error occurs
// It will try to change the base URL to the fallback
const tryFallbackUrl = async () => {
  try {
    console.log('Trying fallback URL:', FALLBACK_URL);
    const isAccessible = await testUrl(FALLBACK_URL);
    if (isAccessible) {
      console.log('Switching to fallback URL:', FALLBACK_URL);
      apiClient.defaults.baseURL = FALLBACK_URL;
      return true;
    }
  } catch (error) {
    console.error('Error testing fallback URL:', error);
  }
  return false;
};

// Cache responses to avoid multiple redundant calls
const responseCache = new Map();
const CACHE_TTL = 30000; // 30 seconds cache lifetime

// Add request interceptor for logging
apiClient.interceptors.request.use(
  (config) => {
    // Generate a cache key for GET requests
    if (config.method.toLowerCase() === 'get') {
      const cacheKey = `${config.method}-${config.url}-${JSON.stringify(config.params || {})}`;
      
      // Check if we have a cached response that's not expired
      const cachedItem = responseCache.get(cacheKey);
      if (cachedItem && Date.now() - cachedItem.timestamp < CACHE_TTL) {
        console.log(`Using cached response for: ${config.method.toUpperCase()} ${config.url}`);
        config.adapter = () => {
          return Promise.resolve({
            data: cachedItem.data,
            status: 200,
            statusText: 'OK',
            headers: cachedItem.headers,
            config: config,
            request: {}
          });
        };
      }
    }
    
    console.log(`Request: ${config.method.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);

// Add response interceptor for logging and error handling
apiClient.interceptors.response.use(
  (response) => {
    console.log(`Response: ${response.status} from ${response.config.url}`);
    
    // Cache successful GET responses
    if (response.config.method.toLowerCase() === 'get') {
      const cacheKey = `${response.config.method}-${response.config.url}-${JSON.stringify(response.config.params || {})}`;
      responseCache.set(cacheKey, {
        data: response.data,
        headers: response.headers,
        timestamp: Date.now()
      });
    }
    
    return response;
  },
  async (error) => {
    // Don't log error for cached responses
    if (error.config?.adapter?.name === 'cachedAdapter') {
      return Promise.reject(error);
    }
    
    console.error(`Error with ${error.config?.method?.toUpperCase()} ${error.config?.url}: ${error.message}`);
    
    // Handle timeout errors with retry mechanism
    const isTimeout = error.code === 'ECONNABORTED' && error.message.includes('timeout');
    
    // If it's a timeout and we haven't retried yet
    if (isTimeout && !error.config._retry) {
      console.log(`Request timed out, retrying with longer timeout...`);
      
      // Mark as retried and increase timeout
      error.config._retry = true;
      error.config.timeout = 30000; // 30 seconds on retry
      
      // Return the promise from the retry
      return apiClient(error.config);
    }
    
    // For network errors, try the fallback URL
    if (error.message.includes('Network Error') && !error.config._fallbackAttempted) {
      error.config._fallbackAttempted = true;
      const switched = await tryFallbackUrl();
      if (switched) {
        return apiClient(error.config);
      }
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;