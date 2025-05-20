import { useState } from 'react';

/**
 * Custom hook for managing form state
 * @param {object} initialValues - Initial form values
 * @returns {array} - Form state and handlers
 */
export const useForm = (initialValues = {}) => {
  const [formData, setFormData] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  /**
   * Handle form input changes
   * @param {Event} e - Input change event
   */
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    
    // Handle different input types
    let parsedValue = value;
    if (type === 'checkbox') {
      parsedValue = checked;
    } else if (type === 'number') {
      parsedValue = value === '' ? '' : Number(value);
    }
    
    setFormData((prev) => ({
      ...prev,
      [name]: parsedValue,
    }));
    
    // Clear error when field is edited
    if (errors[name]) {
      setErrors((prev) => ({
        ...prev,
        [name]: null,
      }));
    }
  };

  /**
   * Set form data programmatically
   * @param {object} newData - New form data
   */
  const setValues = (newData) => {
    setFormData((prev) => ({
      ...prev,
      ...newData,
    }));
  };

  /**
   * Reset form to initial values or new values
   * @param {object} newValues - New values (optional)
   */
  const resetForm = (newValues = initialValues) => {
    setFormData(newValues);
    setErrors({});
  };

  /**
   * Validate form data using provided validator function
   * @param {Function} validatorFn - Validator function
   * @returns {boolean} - Whether form is valid
   */
  const validateForm = (validatorFn) => {
    if (!validatorFn) return true;
    
    const newErrors = validatorFn(formData);
    setErrors(newErrors || {});
    
    return Object.keys(newErrors || {}).length === 0;
  };

  /**
   * Submit form data
   * @param {Event} e - Form submit event
   * @param {Function} submitFn - Submit function
   * @param {Function} validatorFn - Validator function (optional)
   */
  const handleSubmit = async (e, submitFn, validatorFn) => {
    e.preventDefault();
    
    if (isSubmitting) return;
    
    // Validate form if validator function is provided
    if (validatorFn && !validateForm(validatorFn)) {
      return;
    }
    
    try {
      setIsSubmitting(true);
      await submitFn(formData);
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    formData,
    errors,
    isSubmitting,
    handleChange,
    setValues,
    resetForm,
    validateForm,
    handleSubmit,
  };
};

export default useForm;
