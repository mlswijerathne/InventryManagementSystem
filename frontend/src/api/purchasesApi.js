import apiClient from './axiosConfig';

const purchasesApi = {
  getAllPurchases: () => apiClient.get('/purchases/'),
  getPurchaseById: (id) => apiClient.get(`/purchases/${id}/`),
  createPurchase: (purchaseData) => apiClient.post('/purchases/', purchaseData),
  getPurchasesByProduct: (productId) => apiClient.get(`/purchases/product/${productId}/`),
  getRecentPurchases: (limit = 10) => apiClient.get(`/purchases/recent/?limit=${limit}`),
};

export default purchasesApi;
