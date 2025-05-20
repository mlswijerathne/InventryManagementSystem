/**
 * Format a date string
 * @param {string} dateString - Date string to format
 * @param {object} options - Formatting options
 * @returns {string} - Formatted date string
 */
export const formatDate = (dateString, options = {}) => {
  const defaultOptions = { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  };
  
  const formatOptions = { ...defaultOptions, ...options };
  return new Date(dateString).toLocaleDateString(undefined, formatOptions);
};

/**
 * Format a number as a currency
 * @param {number} amount - Amount to format
 * @param {string} currency - Currency code (default: USD)
 * @returns {string} - Formatted currency string
 */
export const formatCurrency = (amount, currency = 'USD') => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency,
  }).format(amount);
};

/**
 * Format a number with thousands separator
 * @param {number} number - Number to format
 * @returns {string} - Formatted number with thousands separators
 */
export const formatNumber = (number) => {
  return new Intl.NumberFormat().format(number);
};

/**
 * Shorten a long string with ellipsis
 * @param {string} str - String to truncate
 * @param {number} maxLength - Maximum length before truncating
 * @returns {string} - Truncated string with ellipsis if necessary
 */
export const truncateString = (str, maxLength = 50) => {
  if (str && str.length > maxLength) {
    return `${str.substring(0, maxLength)}...`;
  }
  return str;
};

/**
 * Parse API error response
 * @param {Error} error - Error object from API call
 * @returns {string} - User-friendly error message
 */
export const parseError = (error) => {
  if (error.response?.data?.error) {
    return error.response.data.error;
  }
  if (error.response?.data?.message) {
    return error.response.data.message;
  }
  if (error.message) {
    return error.message;
  }
  return 'An unknown error occurred';
};

/**
 * Debounce a function call
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 * @returns {Function} - Debounced function
 */
export const debounce = (func, wait = 300) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};
