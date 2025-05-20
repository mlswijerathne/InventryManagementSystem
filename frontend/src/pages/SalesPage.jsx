import { useState, useEffect } from 'react';
import { salesApi, productsApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { PlusIcon, ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

export default function SalesPage() {
  const [sales, setSales] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    product_id: '',
    quantity: '',
    sale_price: '',
  });
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [alertInfo, setAlertInfo] = useState(null);
  // Add sort state - similar to CategoriesPage
  const [sortField, setSortField] = useState('sale_id');
  const [sortDirection, setSortDirection] = useState('desc'); // Default to newest sales first

  // Fetch sales and products
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [salesResponse, productsResponse] = await Promise.all([
          salesApi.getAllSales(),
          productsApi.getAllProducts()
        ]);
        
        setSales(salesResponse.data.data || []);
        setProducts(productsResponse.data.data || []);
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

  // Update sale price when product changes
  useEffect(() => {
    if (formData.product_id) {
      const product = products.find(p => p.product_id.toString() === formData.product_id);
      if (product) {
        setSelectedProduct(product);
        setFormData(prev => ({
          ...prev,
          sale_price: product.price.toString()
        }));
      }
    }
  }, [formData.product_id, products]);

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    let parsedValue = value;
    
    // Convert numeric fields to numbers
    if (name === 'sale_price' || name === 'quantity') {
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
      product_id: '',
      quantity: '',
      sale_price: '',
    });
    setSelectedProduct(null);
  };

  // Show alert message
  const showAlert = (type, message) => {
    setAlertInfo({ type, message });
    setTimeout(() => setAlertInfo(null), 5000);
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (selectedProduct && Number(formData.quantity) > selectedProduct.quantity) {
      showAlert('error', `Not enough stock. Current stock: ${selectedProduct.quantity}`);
      return;
    }
    
    try {
      const saleData = {
        product_id: Number(formData.product_id),
        quantity: Number(formData.quantity),
        sale_price: Number(formData.sale_price),
      };
      
      await salesApi.createSale(saleData);
      showAlert('success', 'Sale recorded successfully!');
      
      // Refresh sales list and products (to get updated stock)
      const [salesResponse, productsResponse] = await Promise.all([
        salesApi.getAllSales(),
        productsApi.getAllProducts()
      ]);
      
      setSales(salesResponse.data.data || []);
      setProducts(productsResponse.data.data || []);
      
      // Reset and hide form
      resetForm();
      setShowForm(false);
    } catch (err) {
      showAlert('error', `Failed to record sale. ${err.response?.data?.error || ''}`);
      console.error('Sale save error:', err);
    }
  };

  // Format date function
  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  // Calculate total
  const calculateTotal = (price, quantity) => {
    return (Number(price || 0) * Number(quantity || 0)).toFixed(2);
  };

  // Sort sales function - similar to CategoriesPage sortCategories
  const sortSales = (field) => {
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

  // Get sorted sales - similar to CategoriesPage getSortedCategories
  const getSortedSales = () => {
    if (!sortField) return sales;
    
    return [...sales].sort((a, b) => {
      let aValue = a[sortField];
      let bValue = b[sortField];
      
      // Handle date field specially
      if (sortField === 'sale_date') {
        aValue = new Date(aValue).getTime();
        bValue = new Date(bValue).getTime();
      }
      // Handle numeric fields
      else if (['sale_id', 'quantity', 'sale_price', 'profit'].includes(sortField)) {
        aValue = parseFloat(aValue) || 0;
        bValue = parseFloat(bValue) || 0;
      }
      // Handle the total field which is calculated
      else if (sortField === 'total') {
        aValue = Number(a.sale_price || 0) * Number(a.quantity || 0);
        bValue = Number(b.sale_price || 0) * Number(b.quantity || 0);
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

  // Table columns definition
  const columns = [
    { field: 'sale_id', header: 'ID', sortable: true },
    { field: 'product_name', header: 'Product', sortable: true },
    { 
      field: 'sale_date', 
      header: 'Date', 
      sortable: true,
      render: (row) => formatDate(row.sale_date)
    },
    { field: 'quantity', header: 'Quantity', sortable: true },
    { 
      field: 'sale_price', 
      header: 'Unit Price', 
      sortable: true,
      render: (row) => `$${Number(row.sale_price || 0).toFixed(2)}`
    },
    { 
      field: 'total', 
      header: 'Total', 
      sortable: true,
      render: (row) => `$${calculateTotal(row.sale_price, row.quantity)}`
    },
    { 
      field: 'profit', 
      header: 'Profit', 
      sortable: true,
      render: (row) => `$${row.profit ? Number(row.profit).toFixed(2) : '0.00'}`
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
          <h1 className="text-2xl font-semibold text-gray-900">Sales</h1>
          <p className="mt-1 text-sm text-gray-500">
            Record and track product sales
          </p>
        </div>
        <Button
          onClick={() => {
            resetForm();
            setShowForm(!showForm);
          }}
          icon={<PlusIcon className="h-5 w-5" />}
        >
          {showForm ? 'Cancel' : 'Record Sale'}
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

      {/* Sale form */}
      {showForm && (
        <div className="bg-white shadow sm:rounded-lg p-6 mb-6">
          <h2 className="text-lg font-medium text-gray-900 mb-4">
            Record New Sale
          </h2>
          <form onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
              <div className="sm:col-span-3">
                <label htmlFor="product_id" className="block text-sm font-medium text-gray-700">
                  Product
                </label>
                <div className="mt-1">
                  <select
                    id="product_id"
                    name="product_id"
                    value={formData.product_id}
                    onChange={handleInputChange}
                    required
                    className="shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  >
                    <option value="">Select a product</option>
                    {products.map(product => (
                      <option key={product.product_id} value={product.product_id} disabled={product.quantity <= 0}>
                        {product.name} {product.quantity <= 0 ? '(Out of Stock)' : `(${product.quantity} in stock)`}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="sm:col-span-3">
                <label htmlFor="quantity" className="block text-sm font-medium text-gray-700">
                  Quantity
                </label>
                <div className="mt-1">
                  <input
                    type="number"
                    name="quantity"
                    id="quantity"
                    min="1"
                    max={selectedProduct ? selectedProduct.quantity : undefined}
                    step="1"
                    value={formData.quantity}
                    onChange={handleInputChange}
                    required
                    className="shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  />
                  {selectedProduct && (
                    <p className="mt-1 text-xs text-gray-500">
                      Available stock: {selectedProduct.quantity}
                    </p>
                  )}
                </div>
              </div>

              <div className="sm:col-span-3">
                <label htmlFor="sale_price" className="block text-sm font-medium text-gray-700">
                  Sale Price ($)
                </label>
                <div className="mt-1">
                  <input
                    type="number"
                    name="sale_price"
                    id="sale_price"
                    min="0"
                    step="0.01"
                    value={formData.sale_price}
                    onChange={handleInputChange}
                    required
                    className="shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  />
                </div>
              </div>

              <div className="sm:col-span-3">
                {formData.quantity && formData.sale_price && (
                  <div className="mt-6">
                    <div className="text-sm text-gray-500">Total:</div>
                    <div className="text-lg font-bold">
                      ${calculateTotal(Number(formData.sale_price), Number(formData.quantity))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div className="mt-6 flex justify-end space-x-3">
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  resetForm();
                  setShowForm(false);
                }}
              >
                Cancel
              </Button>
              <Button type="submit">
                Record Sale
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Sales table with sorting controls */}
      {error ? (
        <Alert type="error" message={error} />
      ) : (
        <div className="bg-white shadow sm:rounded-lg p-6">
          {/* Sort controls - similar to CategoriesPage */}
          <div className="flex justify-between items-center mb-4">
            <div className="flex flex-wrap gap-2">
              {columns
                .filter(column => column.sortable)
                .map(column => (
                  <Button
                    key={column.field}
                    onClick={() => sortSales(column.field)}
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
            data={getSortedSales()}
            emptyMessage="No sales recorded. Record your first sale using the button above."
          />
        </div>
      )}
    </div>
  );
}