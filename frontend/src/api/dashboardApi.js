import apiClient from './axiosConfig';

const dashboardApi = {
  getDashboardOverview: () => apiClient.get('/dashboard/overview'),
  getLowStock: () => apiClient.get('/dashboard/low-stock'),
  getTopSelling: () => apiClient.get('/dashboard/top-selling'),
  getInventorySummary: () => apiClient.get('/dashboard/inventory-summary'),
  getSalesByCategory: () => apiClient.get('/dashboard/sales-by-category'),
};

export default dashboardApi;
