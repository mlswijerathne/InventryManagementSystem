import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { categoriesApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { ArrowLeftIcon, ExclamationCircleIcon, ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';
import { Link } from 'react-router-dom';

export default function CategoryProductsPage() {
  const { categoryId } = useParams();
  const [category, setCategory] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [debugInfo, setDebugInfo] = useState(null);
  // Add sort state - consistent with other pages
  const [sortField, setSortField] = useState('product_id');
  const [sortDirection, setSortDirection] = useState('asc');

  // Define fetchCategoryWithProducts outside useEffect so it can be used by retry button
  const fetchCategoryWithProducts = async () => {
    try {
      setLoading(true);
      console.log('Fetching category products for ID:', categoryId);
      
      const response = await categoriesApi.getCategoryProducts(categoryId);
      console.log('API Response:', response);
      
      // Save debug info
      setDebugInfo({
        responseStatus: response?.status,
        responseData: response?.data,
        apiUrl: `${categoriesApi.getBaseUrl?.() || '(unknown)'}/categories/${categoryId}/products`,
        timestamp: new Date().toISOString()
      });
      
      // Process and validate the response
      if (response && response.data) {
        let categoryData;
        
        // Handle different response structures
        if (response.data.success && response.data.data) {
          // Standard API format
          categoryData = response.data.data;
        } else if (response.data.name) {
          // Direct category object
          categoryData = response.data;
        } else {
          throw new Error('Unexpected data format in response');
        }
        
        // Make sure products is an array and price is a number
        if (categoryData.products) {
          categoryData.products = categoryData.products.map(product => ({
            ...product,
            // Ensure price is a number for toFixed() to work
            price: typeof product.price === 'number' ? product.price : 
                  typeof product.price === 'string' ? parseFloat(product.price) || 0 : 0,
            // Ensure other numeric fields are numbers
            quantity: typeof product.quantity === 'number' ? product.quantity :
                    typeof product.quantity === 'string' ? parseInt(product.quantity) || 0 : 0,
            reorder_level: typeof product.reorder_level === 'number' ? product.reorder_level :
                          typeof product.reorder_level === 'string' ? parseInt(product.reorder_level) || 0 : 0
          }));
        } else {
          categoryData.products = []; // Ensure products is at least an empty array
        }
        
        setCategory(categoryData);
        setError(null);
      } else {
        throw new Error('Invalid response format');
      }
    } catch (err) {
      console.error('Category products fetch error:', err);
      
      // Enhanced error handling with more details
      setDebugInfo({
        errorMessage: err.message,
        errorCode: err.code,
        errorResponse: err.response?.data,
        errorStatus: err.response?.status,
        apiUrl: `${categoriesApi.getBaseUrl?.() || '(unknown)'}/categories/${categoryId}/products`,
        timestamp: new Date().toISOString()
      });
      
      // Handle different error types
      if (err.code === 'ECONNABORTED') {
        setError(`Request timeout: The server took too long to respond. This might indicate the backend is busy processing other requests.`);
      } else if (err.code === 'ERR_NETWORK') {
        setError(`Network Error: Cannot connect to the backend server. Please check if the server is running at http://localhost:5001 or http://127.0.0.1:5001.`);
      } else if (err.response?.status === 404) {
        setError(`Not Found: The category with ID ${categoryId} could not be found.`);
      } else {
        setError(`Failed to load category details: ${err.message || 'Unknown error'}`);
      }
    } finally {
      setLoading(false);
    }
  };

  // Skip the connection test and directly fetch data
  useEffect(() => {
    if (categoryId) {
      fetchCategoryWithProducts();
    }
  }, [categoryId]);

  // Sort products function - similar to other pages
  const sortProducts = (field) => {
    // Only sort if the field is sortable
    const sortableColumn = columns.find(col => col.field === field);
    if (!sortableColumn || !sortableColumn.sortable) return;

    if (sortField === field) {
      // Toggle direction if clicking the same field
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      // Set new field and default to ascending
      setSortField(field);
      setSortDirection('asc');
    }
  };

  // Get sorted products - similar to other pages
  const getSortedProducts = () => {
    if (!category || !category.products || !sortField) return category?.products || [];
    
    return [...category.products].sort((a, b) => {
      let aValue = a[sortField];
      let bValue = b[sortField];
      
      // Handle numeric fields
      if (['product_id', 'price', 'quantity', 'reorder_level'].includes(sortField)) {
        aValue = parseFloat(aValue) || 0;
        bValue = parseFloat(bValue) || 0;
      }
      // Handle text fields
      else if (typeof aValue === 'string') {
        aValue = aValue?.toLowerCase() || '';
        bValue = bValue?.toLowerCase() || '';
      }
      
      // Handle null or undefined values
      if (aValue === null || aValue === undefined) return sortDirection === 'asc' ? -1 : 1;
      if (bValue === null || bValue === undefined) return sortDirection === 'asc' ? 1 : -1;
      
      // Compare
      const comparison = aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
      return sortDirection === 'asc' ? comparison : -comparison;
    });
  };

  // Table columns definition with more robust rendering
  const columns = [
    { field: 'product_id', header: 'ID', sortable: true },
    { field: 'name', header: 'Name', sortable: true },
    { 
      field: 'price', 
      header: 'Price', 
      sortable: true,
      render: (row) => {
        // Safely handle price field
        const price = typeof row.price === 'number' ? row.price : 
                      typeof row.price === 'string' ? parseFloat(row.price) || 0 : 0;
        return `$${price.toFixed(2)}`;
      }
    },
    { 
      field: 'quantity', 
      header: 'Stock', 
      sortable: true,
      render: (row) => {
        // Safely handle quantity field
        return typeof row.quantity === 'number' ? row.quantity : 
               typeof row.quantity === 'string' ? parseInt(row.quantity) || 0 : 0;
      }
    },
    { 
      field: 'reorder_level', 
      header: 'Reorder Level', 
      sortable: true,
      render: (row) => {
        // Safely handle reorder_level field
        return typeof row.reorder_level === 'number' ? row.reorder_level :
               typeof row.reorder_level === 'string' ? parseInt(row.reorder_level) || 0 : 0;
      }
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-4">
        <Alert type="error" message={error} />
        
        {/* Debug information for developers */}
        {debugInfo && (
          <div className="bg-gray-100 p-4 rounded-md">
            <details>
              <summary className="flex items-center text-sm font-medium text-gray-700 cursor-pointer">
                <ExclamationCircleIcon className="h-5 w-5 mr-2 text-yellow-500" />
                Show Debug Information
              </summary>
              <pre className="mt-4 bg-gray-800 text-white p-4 rounded-md overflow-auto text-xs">
                {JSON.stringify(debugInfo, null, 2)}
              </pre>
            </details>
          </div>
        )}
        
        <div className="flex space-x-4">
          <Button 
            variant="primary" 
            onClick={() => {
              setError(null);
              setLoading(true);
              fetchCategoryWithProducts();
            }}
          >
            Retry
          </Button>
          <Link to="/categories">
            <Button variant="outline">
              Back to Categories
            </Button>
          </Link>
        </div>
      </div>
    );
  }

  if (!category) {
    return (
      <div className="space-y-4">
        <Alert type="info" message="Category not found or empty response received." />
        
        {/* Debug information for developers */}
        {debugInfo && (
          <div className="bg-gray-100 p-4 rounded-md">
            <details>
              <summary className="flex items-center text-sm font-medium text-gray-700 cursor-pointer">
                <ExclamationCircleIcon className="h-5 w-5 mr-2 text-yellow-500" />
                Show Debug Information
              </summary>
              <pre className="mt-4 bg-gray-800 text-white p-4 rounded-md overflow-auto text-xs">
                {JSON.stringify(debugInfo, null, 2)}
              </pre>
            </details>
          </div>
        )}
        
        <Link to="/categories">
          <Button variant="outline">
            Back to Categories
          </Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <div className="flex items-center mb-4">
          <Link to="/categories" className="mr-4">
            <Button variant="outline" size="sm" icon={<ArrowLeftIcon className="h-4 w-4" />}>
              Back to Categories
            </Button>
          </Link>
        </div>
        <h1 className="text-2xl font-semibold text-gray-900">{category.name} Products</h1>
        <p className="mt-1 text-sm text-gray-500">
          {category.description || 'No description available'}
        </p>
      </div>

      {/* Products table with sorting controls */}
      <div className="bg-white shadow sm:rounded-lg p-6">
        {/* Sort controls - consistent with other pages */}
        <div className="flex justify-between items-center mb-4">
          <div className="flex flex-wrap gap-2">
            {columns
              .filter(column => column.sortable)
              .map(column => (
                <Button
                  key={column.field}
                  onClick={() => sortProducts(column.field)}
                  variant={sortField === column.field ? 'primary' : 'outline'}
                  size="sm"
                  className="flex items-center"
                >
                  {column.header}
                  {sortField === column.field && (
                    sortDirection === 'asc' 
                      ? <ChevronUpIcon className="h-4 w-4 ml-1" />
                      : <ChevronDownIcon className="h-4 w-4 ml-1" />
                  )}
                </Button>
              ))}
          </div>
        </div>

        <DataTable
          columns={columns}
          data={getSortedProducts()}
          emptyMessage={`No products found in the "${category.name}" category.`}
        />
      </div>

      <div className="mt-6">
        <Link to="/products">
          <Button variant="primary">
            Manage Products
          </Button>
        </Link>
      </div>
    </div>
  );
}