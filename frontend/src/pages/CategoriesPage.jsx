import { useState, useEffect } from 'react';
import { categoriesApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { PlusIcon, PencilIcon, TrashIcon, ListBulletIcon, ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';
import { useNavigate } from 'react-router-dom';

export default function CategoriesPage() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
  });
  const [isEditing, setIsEditing] = useState(false);
  const [currentCategoryId, setCurrentCategoryId] = useState(null);
  const [alertInfo, setAlertInfo] = useState(null);
  // Add sort state
  const [sortField, setSortField] = useState('name');
  const [sortDirection, setSortDirection] = useState('asc');

  const navigate = useNavigate();

  // Fetch categories
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        setLoading(true);
        const response = await categoriesApi.getAllCategories();
        setCategories(response.data.data || []);
        setError(null);
      } catch (err) {
        setError('Failed to load categories. Please try again later.');
        console.error('Categories fetch error:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchCategories();
  }, []);

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  // Reset form
  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
    });
    setIsEditing(false);
    setCurrentCategoryId(null);
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
      const categoryData = {
        name: formData.name,
        description: formData.description
      };
      
      if (isEditing && currentCategoryId) {
        await categoriesApi.updateCategory(currentCategoryId, categoryData);
        showAlert('success', 'Category updated successfully!');
      } else {
        await categoriesApi.createCategory(categoryData);
        showAlert('success', 'Category created successfully!');
      }
      
      // Refresh categories list
      const response = await categoriesApi.getAllCategories();
      setCategories(response.data.data || []);
      
      // Reset and hide form
      resetForm();
      setShowForm(false);
    } catch (err) {
      showAlert('error', `Failed to ${isEditing ? 'update' : 'create'} category. ${err.response?.data?.error || ''}`);
      console.error('Category save error:', err);
    }
  };

  // Handle edit category
  const handleEdit = (category) => {
    setFormData({
      name: category.name,
      description: category.description || '',
    });
    setIsEditing(true);
    setCurrentCategoryId(category.category_id);
    setShowForm(true);
  };

  // Handle delete category
  const handleDelete = async (categoryId) => {
    if (!window.confirm('Are you sure you want to delete this category?')) {
      return;
    }
    
    try {
      await categoriesApi.deleteCategory(categoryId);
      showAlert('success', 'Category deleted successfully!');
      
      // Update categories list
      setCategories(categories.filter(c => c.category_id !== categoryId));
    } catch (err) {
      showAlert('error', `Failed to delete category. ${err.response?.data?.error || ''}`);
      console.error('Category delete error:', err);
    }
  };

  // Handle view category products
  const handleViewProducts = (categoryId) => {
    navigate(`/categories/${categoryId}/products`);
  };

  // Sort categories function
  const sortCategories = (field) => {
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

  // Get sorted categories
  const getSortedCategories = () => {
    if (!sortField) return categories;
    
    return [...categories].sort((a, b) => {
      let aValue = a[sortField];
      let bValue = b[sortField];
      
      // Handle numeric fields by explicitly converting to numbers
      if (['category_id', 'product_count'].includes(sortField)) {
        aValue = parseFloat(aValue) || 0;
        bValue = parseFloat(bValue) || 0;
      } else if (typeof aValue === 'string') {
        // Handle text fields
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
    { field: 'category_id', header: 'ID', sortable: true },
    { field: 'name', header: 'Name', sortable: true },
    { field: 'description', header: 'Description', sortable: true },
    { field: 'product_count', header: 'Products', sortable: true },
    { 
      field: 'actions', 
      header: 'Actions',
      sortable: false,
      render: (row) => (
        <div className="flex space-x-2">
          <Button
            onClick={(e) => {
              e.stopPropagation();
              handleViewProducts(row.category_id);            
            }}
            variant="outline"
            size="sm"
            icon={<ListBulletIcon className="h-4 w-4" />}
          >
            Products
          </Button>
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
              handleDelete(row.category_id);
            }}
            variant="danger"
            size="sm"
            icon={<TrashIcon className="h-4 w-4" />}
            disabled={row.product_count > 0}
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
          <h1 className="text-2xl font-semibold text-gray-900">Categories</h1>
          <p className="mt-1 text-sm text-gray-500">
            Manage product categories
          </p>
        </div>
        <Button
          onClick={() => {
            resetForm();
            setShowForm(!showForm);
          }}
          icon={<PlusIcon className="h-5 w-5" />}
        >
          {showForm ? 'Cancel' : 'Add Category'}
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

      {/* Category form */}
      {showForm && (
        <div className="bg-white shadow sm:rounded-lg p-6 mb-6">
          <h2 className="text-lg font-medium text-gray-900 mb-4">
            {isEditing ? 'Edit Category' : 'Add New Category'}
          </h2>
          <form onSubmit={handleSubmit}>
            <div className="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
              <div className="sm:col-span-3">
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                  Category Name
                </label>
                <div className="mt-1">
                  <input
                    type="text"
                    name="name"
                    id="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    required
                    className="shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  />
                </div>
              </div>

              <div className="sm:col-span-6">
                <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                  Description
                </label>
                <div className="mt-1">
                  <textarea
                    id="description"
                    name="description"
                    rows={3}
                    value={formData.description}
                    onChange={handleInputChange}
                    className="shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md"
                  />
                </div>
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
                {isEditing ? 'Update Category' : 'Create Category'}
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Categories table */}
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
                    onClick={() => sortCategories(column.field)}
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
            data={getSortedCategories()}
            emptyMessage="No categories found. Add your first category using the button above."
          />
        </div>
      )}
    </div>
  );
}