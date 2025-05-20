import apiClient from './axiosConfig';

const productsApi = {
  getAllProducts: () => apiClient.get('/products'),
  getProductById: (id) => apiClient.get(`/products/${id}`),
  createProduct: (productData) => apiClient.post('/products', productData),
  updateProduct: (id, productData) => apiClient.put(`/products/${id}`, productData),
  deleteProduct: (id) => apiClient.delete(`/products/${id}`),
  getLowStockProducts: () => apiClient.get('/products/low-stock'),
  getTopSellingProducts: (limit = 5) => apiClient.get(`/products/top-selling?limit=${limit}`),
  getInventorySummary: () => apiClient.get('/products/inventory-summary'),
};

export default productsApi;
