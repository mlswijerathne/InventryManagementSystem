import { useState } from 'react';

/**
 * Custom hook for handling API requests with loading and error states
 * @param {Function} apiFunction - API function to execute
 * @returns {Object} - States and handler function for API requests
 */
export const useApiRequest = (apiFunction) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [data, setData] = useState(null);

  /**
   * Execute API request with error handling
   * @param {Array} params - Parameters to pass to the API function
   * @returns {Object} - Response data or null if error
   */
  const execute = async (...params) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiFunction(...params);
      setData(response.data);
      
      return response.data;
    } catch (err) {
      const errorMessage = err.response?.data?.error || err.message || 'An error occurred';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  };

  /**
   * Reset error state
   */
  const resetError = () => {
    setError(null);
  };

  /**
   * Reset all states
   */
  const reset = () => {
    setLoading(false);
    setError(null);
    setData(null);
  };

  return { loading, error, data, execute, resetError, reset };
};

export default useApiRequest;
