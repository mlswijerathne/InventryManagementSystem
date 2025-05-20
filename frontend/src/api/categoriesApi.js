import apiClient from './axiosConfig';

const categoriesApi = {
  getAllCategories: () => apiClient.get('/categories'),
  getCategoryById: (id) => apiClient.get(`/categories/${id}`),
  createCategory: (categoryData) => apiClient.post('/categories', categoryData),
  updateCategory: (id, categoryData) => apiClient.put(`/categories/${id}`, categoryData),
  deleteCategory: (id) => apiClient.delete(`/categories/${id}`),
  getCategoryProducts: (id) => apiClient.get(`/categories/${id}/products`),
};

export default categoriesApi;
