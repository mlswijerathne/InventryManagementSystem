import apiClient from './axiosConfig';

const categoriesApi = {
  // Return base URL for debugging
  getBaseUrl: () => apiClient.defaults.baseURL,
  
  // Standard API methods
  getAllCategories: () => apiClient.get('/categories/'),
  getCategoryById: (id) => apiClient.get(`/categories/${id}/`),
  createCategory: (categoryData) => apiClient.post('/categories/', categoryData),
  updateCategory: (id, categoryData) => apiClient.put(`/categories/${id}/`, categoryData),
  deleteCategory: (id) => apiClient.delete(`/categories/${id}/`),
  
  // Improved category products method with better diagnostics
  getCategoryProducts: async (id) => {
    try {
      console.log(`Fetching products for category ID: ${id}`);
      console.log(`Current API base URL: ${apiClient.defaults.baseURL}`);
      
      // Try without trailing slash first (as in your code)
      const url = `/categories/${id}/products`;
      console.log(`Making request to: ${apiClient.defaults.baseURL}${url}`);
      
      const response = await apiClient.get(url);
      console.log('Category products API response:', response);
      return response;
    } catch (error) {
      console.error(`Error fetching category ${id} products:`, error);
      
      // If it's a network error, try with a different URL format
      if (error.code === 'ERR_NETWORK' || error.response?.status === 404) {
        console.error('Network error or 404 detected. Trying alternative approach...');
        
        try {
          // Try with trailing slash
          console.log('Trying with trailing slash...');
          const urlWithSlash = `/categories/${id}/products/`;
          const response = await apiClient.get(urlWithSlash);
          console.log('Success with trailing slash:', response);
          return response;
        } catch (slashError) {
          console.error('Attempt with trailing slash failed:', slashError);
        }
        
        // Try with the other hostname (localhost vs 127.0.0.1)
        try {
          const alternativeBaseUrl = apiClient.defaults.baseURL.includes('localhost') 
            ? 'http://127.0.0.1:5001/api' 
            : 'http://localhost:5001/api';
            
          console.log(`Trying alternative base URL: ${alternativeBaseUrl}`);
          
          const directResponse = await fetch(`${alternativeBaseUrl}/categories/${id}/products`);
          if (directResponse.ok) {
            const data = await directResponse.json();
            console.log('Direct fetch successful:', data);
            return { data };
          } else {
            console.error('Direct fetch failed with status:', directResponse.status);
          }
        } catch (directError) {
          console.error('Direct fetch failed:', directError);
        }
      }
      
      // Rethrow the original error if all attempts fail
      throw error;
    }
  },
  
  // Test method that helps diagnose connection issues
  testConnection: async () => {
    const results = {};
    
    // Test both hostnames and both with/without trailing slashes
    const testUrls = [
      'http://localhost:5001/api/categories/test-connection',
      'http://localhost:5001/api/categories/test-connection/',
      'http://127.0.0.1:5001/api/categories/test-connection',
      'http://127.0.0.1:5001/api/categories/test-connection/'
    ];
    
    for (const url of testUrls) {
      try {
        console.log(`Testing connection to: ${url}`);
        const response = await fetch(url, { timeout: 3000 });
        const data = await response.json();
        results[url] = { success: true, status: response.status, data };
        console.log(`Connection to ${url} successful:`, data);
      } catch (error) {
        results[url] = { success: false, error: error.message };
        console.error(`Connection to ${url} failed:`, error);
      }
    }
    
    return results;
  }
};

export default categoriesApi;