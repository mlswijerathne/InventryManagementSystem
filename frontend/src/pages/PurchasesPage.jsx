import { useState, useEffect } from 'react';
import { purchasesApi, productsApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { PlusIcon, ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

export default function PurchasesPage() {
  const [purchases, setPurchases] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);  const [formData, setFormData] = useState({
    product_id: '',
    quantity: '',
    purchase_price: '',
    supplier: ''
  });
  const [alertInfo, setAlertInfo] = useState(null);
  const [sortField, setSortField] = useState('purchase_id');
  const [sortDirection, setSortDirection] = useState('desc');

  // Fetch purchases and products
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [purchasesResponse, productsResponse] = await Promise.all([
          purchasesApi.getAllPurchases(),
          productsApi.getAllProducts()
        ]);
        
        setPurchases(purchasesResponse.data.data || []);
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
  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    let parsedValue = value;
    
    // Convert numeric fields to numbers
    if (name === 'purchase_price' || name === 'quantity') {
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
      purchase_price: '',
      supplier: ''
    });
  };

  // Show alert message
  const showAlert = (type, message) => {
    setAlertInfo({ type, message });
    setTimeout(() => setAlertInfo(null), 5000);
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
      try {
      const purchaseData = {
        product_id: Number(formData.product_id),
        quantity: Number(formData.quantity),
        purchase_price: Number(formData.purchase_price),
        supplier: formData.supplier
      };
      
      await purchasesApi.createPurchase(purchaseData);
      showAlert('success', 'Purchase recorded successfully!');
      
      // Refresh purchases list
      const response = await purchasesApi.getAllPurchases();
      setPurchases(response.data.data || []);
      
      // Reset and hide form
      resetForm();
      setShowForm(false);
    } catch (err) {
      showAlert('error', `Failed to record purchase. ${err.response?.data?.error || ''}`);
      console.error('Purchase save error:', err);
    }
  };

  // Format date function
  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  // Handle sorting
  const handleSort = (field) => {
    if (sortField === field) {
      // Toggle direction if clicking the same field
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      // Set new field and default to ascending
      setSortField(field);
      setSortDirection('asc');
    }
  };

  // Get sorted purchases
  const getSortedPurchases = () => {
    if (!sortField) return purchases;
    
    return [...purchases].sort((a, b) => {
      let aValue = a[sortField];
      let bValue = b[sortField];
      
      // Handle special cases
      if (sortField === 'purchase_date') {
        aValue = new Date(aValue).getTime();
        bValue = new Date(bValue).getTime();
      } else if (['purchase_price', 'quantity'].includes(sortField)) {
        aValue = Number(aValue || 0);
        bValue = Number(bValue || 0);
      } else if (sortField === 'total_cost') {
        aValue = Number(a.purchase_price || 0) * Number(a.quantity || 0);
        bValue = Number(b.purchase_price || 0) * Number(b.quantity || 0);
      } else if (typeof aValue === 'string' && typeof bValue === 'string') {
        aValue = aValue.toLowerCase();
        bValue = bValue.toLowerCase();
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
    { field: 'purchase_id', header: 'ID', sortable: true },
    { field: 'product_name', header: 'Product', sortable: true },
    { 
      field: 'purchase_date', 
      header: 'Date', 
      sortable: true,
      render: (row) => formatDate(row.purchase_date)
    },
    { field: 'quantity', header: 'Quantity', sortable: true },    
    { 
      field: 'purchase_price', 
      header: 'Unit Price', 
      sortable: true,
      render: (row) => `${Number(row.purchase_price || 0).toFixed(2)}`
    },    
    { 
      field: 'total_cost', 
      header: 'Total', 
      sortable: true,
      render: (row) => `${(Number(row.purchase_price || 0) * Number(row.quantity || 0)).toFixed(2)}`
    },
    { field: 'supplier', header: 'Supplier', sortable: true },
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
          <h1 className="text-2xl font-semibold text-gray-900">Purchases</h1>
          <p className="mt-1 text-sm text-gray-500">
            Record and track product purchases
          </p>
        </div>
        <Button
          onClick={() => {
            resetForm();
            setShowForm(!showForm);
          }}
          icon={<PlusIcon className="h-5 w-5" />}
        >
          {showForm ? 'Cancel' : 'Record Purchase'}
        </Button>
      </div>

      {/* Alert message */}
      {alertInfo && (
        <Alert 
          type={alertInfo.type} 
          message={alertInfo.message} 
          onClose={() => setAlertInfo(null)} 
        />
      )}      {/* Purchase form */}
      {showForm && (
        <div className="bg-white shadow-xl sm:rounded-lg p-8 mb-6 border border-gray-100">
          <div className="flex items-center mb-6 border-b border-gray-100 pb-4">
            <div className="p-3 rounded-full bg-blue-50 text-blue-500 mr-4">
              <PlusIcon className="h-6 w-6" />
            </div>
            <h2 className="text-xl font-semibold text-gray-800">
              Record New Purchase
            </h2>
          </div>
          <form onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 gap-y-6 gap-x-6 sm:grid-cols-6">
              <div className="sm:col-span-3">
                <label htmlFor="product_id" className="block text-sm font-medium text-gray-700">
                  Product
                </label>
                <div className="mt-1 relative">
                  <select
                    id="product_id"
                    name="product_id"
                    value={formData.product_id}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full px-4 py-3 sm:text-sm border border-gray-200 rounded-lg bg-gray-50 transition-colors"
                  >
                    <option value="">Select a product</option>
                    {products.map(product => (
                      <option key={product.product_id} value={product.product_id}>
                        {product.name}
                      </option>                    ))}
                  </select>
                </div>
              </div>

              <div className="sm:col-span-3">
                <label htmlFor="supplier" className="block text-sm font-medium text-gray-700">
                  Supplier
                </label>
                <div className="mt-1 relative">
                  <input
                    type="text"
                    name="supplier"
                    id="supplier"
                    value={formData.supplier}
                    onChange={handleInputChange}
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full px-4 py-3 sm:text-sm border border-gray-200 rounded-lg bg-gray-50 transition-colors"
                  />
                </div>
              </div>              <div className="sm:col-span-2">
                <label htmlFor="quantity" className="block text-sm font-medium text-gray-700">
                  Quantity
                </label>
                <div className="mt-1 relative">
                  <input
                    type="number"
                    name="quantity"
                    id="quantity"
                    min="1"
                    step="1"
                    value={formData.quantity}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full px-4 py-3 sm:text-sm border border-gray-200 rounded-lg bg-gray-50 transition-colors"
                  />
                </div>
              </div>              <div className="sm:col-span-2">
                <label htmlFor="purchase_price" className="block text-sm font-medium text-gray-700">
                  Purchase Price ($)
                </label>
                <div className="mt-1 relative">
                  <input
                    type="number"
                    name="purchase_price"
                    id="purchase_price"
                    min="0"
                    step="0.01"
                    value={formData.purchase_price}
                    onChange={handleInputChange}
                    required
                    className="focus:ring-blue-500 focus:border-blue-500 block w-full px-4 py-3 sm:text-sm border border-gray-200 rounded-lg bg-gray-50 transition-colors"
                  />
                </div>
              </div>
            </div>            <div className="mt-8 pt-5 border-t border-gray-100 flex justify-end space-x-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  resetForm();
                  setShowForm(false);
                }}
                className="border-gray-300 text-gray-700 hover:bg-gray-50 px-5"
              >
                Cancel
              </Button>
              <Button 
                type="submit"
                className="bg-blue-500 hover:bg-blue-600 px-5"
              >
                Record Purchase
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Purchases table */}
      {error ? (
        <Alert type="error" message={error} />
      ) : (
        <div className="bg-white shadow sm:rounded-lg p-6">
          {/* Sort controls */}
          <div className="flex justify-between items-center mb-4">
            <div className="flex flex-wrap gap-2">
              {columns
                .filter(column => column.sortable)
                .map(column => (
                  <Button
                    key={column.field}
                    onClick={() => handleSort(column.field)}
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
            data={getSortedPurchases()}
            emptyMessage="No purchases recorded. Record your first purchase using the button above."
          />
        </div>
      )}
    </div>
  );
}