import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { categoriesApi } from '../api';
import DataTable from '../components/DataTable';
import Button from '../components/Button';
import Alert from '../components/Alert';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import { Link } from 'react-router-dom';

export default function CategoryProductsPage() {
  const { categoryId } = useParams();
  const [category, setCategory] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCategoryWithProducts = async () => {
      try {
        setLoading(true);
        const response = await categoriesApi.getCategoryProducts(categoryId);
        setCategory(response.data.data || null);
        setError(null);
      } catch (err) {
        setError('Failed to load category details. Please try again later.');
        console.error('Category products fetch error:', err);
      } finally {
        setLoading(false);
      }
    };

    if (categoryId) {
      fetchCategoryWithProducts();
    }
  }, [categoryId]);

  // Table columns definition
  const columns = [
    { field: 'product_id', header: 'ID', sortable: true },
    { field: 'name', header: 'Name', sortable: true },
    { 
      field: 'price', 
      header: 'Price', 
      sortable: true,
      render: (row) => `$${row.price.toFixed(2)}`
    },
    { field: 'quantity', header: 'Stock', sortable: true },
    { field: 'reorder_level', header: 'Reorder Level', sortable: true },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return <Alert type="error" message={error} />;
  }

  if (!category) {
    return <Alert type="info" message="Category not found." />;
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

      {/* Products table */}
      <DataTable
        columns={columns}
        data={category.products || []}
        emptyMessage={`No products found in the "${category.name}" category.`}
      />

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
