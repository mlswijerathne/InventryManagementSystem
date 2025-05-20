import apiClient from './axiosConfig';

const salesApi = {
  getAllSales: () => apiClient.get('/sales'),
  getSaleById: (id) => apiClient.get(`/sales/${id}`),
  createSale: (saleData) => apiClient.post('/sales', saleData),
  getSalesByProduct: (productId) => apiClient.get(`/sales/product/${productId}`),
  getRecentSales: (limit = 10) => apiClient.get(`/sales/recent?limit=${limit}`),
  getTopSelling: (limit = 5) => apiClient.get(`/sales/top-selling?limit=${limit}`),
  getSalesByCategory: () => apiClient.get('/sales/by-category'),
};

export default salesApi;
