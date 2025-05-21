import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { productsApi, categoriesApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { PlusIcon, TrashIcon, PencilIcon, ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

export default function ProductsPage() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    category_id: '',
    price: '',
    quantity: '',
    reorder_level: ''
  });
  const [isEditing, setIsEditing] = useState(false);
  const [currentProductId, setCurrentProductId] = useState(null);
  const [alertInfo, setAlertInfo] = useState(null);
  // Add sort state
  const [sortField, setSortField] = useState('name');
  const [sortDirection, setSortDirection] = useState('asc');

  const navigate = useNavigate();

  // Fetch products and categories
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [productsResponse, categoriesResponse] = await Promise.all([
          productsApi.getAllProducts(),
          categoriesApi.getAllCategories()
        ]);
        
        setProducts(productsResponse.data.data || []);
        setCategories(categoriesResponse.data.data || []);
        setError(null);
      } catch (err) {
        setError('Failed to load data. Please try again later.');
        console.error('Data fetch error:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    let parsedValue = value;
    
    // Convert numeric fields to numbers
    if (name === 'price' || name === 'quantity' || name === 'reorder_level') {
      parsedValue = value === '' ? '' : Number(value);
    }
    
    setFormData({
      ...formData,
      [name]: parsedValue
    });
  };

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      category_id: '',
      price: '',
      quantity: '',
      reorder_level: ''
    });
    setIsEditing(false);
    setCurrentProductId(null);
  };

  // Show alert message
  const showAlert = (type, message) => {
    setAlertInfo({ type, message });
    setTimeout(() => setAlertInfo(null), 5000); // Auto-dismiss after 5 seconds
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      const productData = {
        name: formData.name,
        category_id: Number(formData.category_id),
        price: Number(formData.price),
        quantity: Number(formData.quantity || 0),
        reorder_level: Number(formData.reorder_level || 10)
      };
      
      if (isEditing && currentProductId) {
        await productsApi.updateProduct(currentProductId, productData);
        showAlert('success', 'Product updated successfully!');
      } else {
        await productsApi.createProduct(productData);
        showAlert('success', 'Product created successfully!');
      }
      
      // Refresh products list
      const response = await productsApi.getAllProducts();
      setProducts(response.data.data || []);
      
      // Reset and hide form
      resetForm();
      setShowForm(false);
    } catch (err) {
      showAlert('error', `Failed to ${isEditing ? 'update' : 'create'} product. ${err.response?.data?.error || ''}`);
      console.error('Product save error:', err);
    }
  };

  // Handle edit product
  const handleEdit = (product) => {
    setFormData({
      name: product.name,
      category_id: product.category_id.toString(),
      price: product.price.toString(),
      quantity: product.quantity.toString(),
      reorder_level: product.reorder_level.toString()
    });
    setIsEditing(true);
    setCurrentProductId(product.product_id);
    setShowForm(true);
  };

  // Handle delete product
  const handleDelete = async (productId) => {
    if (!window.confirm('Are you sure you want to delete this product?')) {
      return;
    }
    
    try {
      await productsApi.deleteProduct(productId);
      showAlert('success', 'Product deleted successfully!');
      
      // Update products list
      setProducts(products.filter(p => p.product_id !== productId));
    } catch (err) {
      showAlert('error', `Failed to delete product. ${err.response?.data?.error || ''}`);
      console.error('Product delete error:', err);
    }
  };

  // Sort products function - FIXED
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

  // Get sorted products - FIXED for proper numeric sorting
  const getSortedProducts = () => {
    if (!sortField) return products;
    
    return [...products].sort((a, b) => {
      let aValue, bValue;
      
      // Special case for category_name which comes from a relationship
      if (sortField === 'category_name') {
        // Get category names safely
        const aCat = categories.find(c => c.category_id === a.category_id)?.name;
        const bCat = categories.find(c => c.category_id === b.category_id)?.name;
        aValue = aCat?.toLowerCase() || '';
        bValue = bCat?.toLowerCase() || '';
      } else {
        // Normal field
        aValue = a[sortField];
        bValue = b[sortField];
        
        // Handle numeric fields by explicitly converting to numbers
        if (['product_id', 'price', 'quantity', 'reorder_level'].includes(sortField)) {
          aValue = parseFloat(aValue) || 0;
          bValue = parseFloat(bValue) || 0;
        } else if (typeof aValue === 'string') {
          // Handle text fields
          aValue = aValue.toLowerCase();
          bValue = (bValue || '').toLowerCase();
        }
      }
      
      // Handle null or undefined values
      if (aValue === null || aValue === undefined) return sortDirection === 'asc' ? -1 : 1;
      if (bValue === null || bValue === undefined) return sortDirection === 'asc' ? 1 : -1;
      
      // Compare
      const comparison = aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
      return sortDirection === 'asc' ? comparison : -comparison;
    });
  };

  // Table columns definition - sortable flags added correctly
  const columns = [
    { field: 'product_id', header: 'ID', sortable: true },
    { field: 'name', header: 'Name', sortable: true },
    { field: 'category_name', header: 'Category', sortable: true },
    { 
      field: 'price', 
      header: 'Price', 
      sortable: true,
      render: (row) => `$${Number(row.price || 0).toFixed(2)}`
    },
    { field: 'quantity', header: 'Stock', sortable: true },
    { 
      field: 'actions', 
      header: 'Actions',
      sortable: false,
      render: (row) => (
        <div className="flex space-x-2">
          <Button
            onClick={(e) => {
              e.stopPropagation();
              handleEdit(row);
            }}
            variant="secondary"
            size="sm"
            icon={<PencilIcon className="h-4 w-4" />}
          >
            Edit
          </Button>
          <Button
            onClick={(e) => {
              e.stopPropagation();
              handleDelete(row.product_id);
            }}
            variant="danger"
            size="sm"
            icon={<TrashIcon className="h-4 w-4" />}
          >
            Delete
          </Button>
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">Products</h1>
          <p className="mt-1 text-sm text-gray-500">
            Manage your inventory products
          </p>
        </div>
        <Button
          onClick={() => {
            resetForm();
            setShowForm(!showForm);
          }}
          icon={<PlusIcon className="h-5 w-5" />}
        >
          {showForm ? 'Cancel' : 'Add Product'}
        </Button>
      </div>

      {/* Alert message */}
      {alertInfo && (
        <Alert 
          type={alertInfo.type} 
          message={alertInfo.message} 
          onClose={() => setAlertInfo(null)} 
        />
      )}

      {/* Product form - Updated with enhanced theme */}
      {showForm && (
        <div className="bg-gradient-to-br from-blue-50 to-indigo-50 shadow-lg sm:rounded-lg p-6 mb-6 border border-blue-200">
          <div className="flex items-center mb-6 border-b border-blue-200 pb-4">
            <div className={`p-3 rounded-full ${isEditing ? 'bg-amber-100 text-amber-600' : 'bg-blue-100 text-blue-600'} mr-4`}>
              {isEditing ? (
                <PencilIcon className="h-6 w-6" />
              ) : (
                <PlusIcon className="h-6 w-6" />
              )}
            </div>
            <h2 className="text-xl font-semibold text-gray-800">
              {isEditing ? 'Edit Product' : 'Add New Product'}
            </h2>
          </div>
          
          <form onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
              <div className="sm:col-span-3">
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                  Product Name
                </label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <input
                    type="text"
                    name="name"
                    id="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md bg-white"
                    placeholder="Enter product name"
                  />
                </div>
              </div>

              <div className="sm:col-span-3">
                <label htmlFor="category_id" className="block text-sm font-medium text-gray-700">
                  Category
                </label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <select
                    id="category_id"
                    name="category_id"
                    value={formData.category_id}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md bg-white"
                  >
                    <option value="">Select a category</option>
                    {categories.map(category => (
                      <option key={category.category_id} value={category.category_id}>
                        {category.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="sm:col-span-2">
                <label htmlFor="price" className="block text-sm font-medium text-gray-700">
                  Price ($)
                </label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span className="text-gray-500 sm:text-sm">$</span>
                  </div>
                  <input
                    type="number"
                    name="price"
                    id="price"
                    min="0"
                    step="0.01"
                    value={formData.price}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full pl-7 sm:text-sm border-gray-300 rounded-md bg-white"
                    placeholder="0.00"
                  />
                </div>
              </div>

              <div className="sm:col-span-2">
                <label htmlFor="quantity" className="block text-sm font-medium text-gray-700">
                  Quantity
                </label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <input
                    type="number"
                    name="quantity"
                    id="quantity"
                    min="0"
                    value={formData.quantity}
                    onChange={handleInputChange}
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md bg-white"
                    placeholder="0"
                  />
                </div>
              </div>

              <div className="sm:col-span-2">
                <label htmlFor="reorder_level" className="block text-sm font-medium text-gray-700">
                  Reorder Level
                </label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <input
                    type="number"
                    name="reorder_level"
                    id="reorder_level"
                    min="0"
                    value={formData.reorder_level}
                    onChange={handleInputChange}
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md bg-white"
                    placeholder="10"
                  />
                </div>
              </div>
            </div>

            <div className="mt-8 pt-4 border-t border-blue-200 flex justify-end space-x-3">
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  resetForm();
                  setShowForm(false);
                }}
                className="border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </Button>
              <Button 
                type="submit"
                className={`${isEditing ? 'bg-amber-600 hover:bg-amber-700' : 'bg-blue-600 hover:bg-blue-700'}`}
              >
                {isEditing ? 'Update Product' : 'Create Product'}
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Products table */}
      {error ? (
        <Alert type="error" message={error} />
      ) : (
        <div className="bg-white shadow sm:rounded-lg p-6">
          {/* Sort controls - FIXED to exclude actions column */}
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
            onRowClick={(product) => navigate(`/products/${product.product_id}`)}
            emptyMessage="No products found. Add your first product using the button above."
          />
        </div>
      )}
    </div>
  );
}