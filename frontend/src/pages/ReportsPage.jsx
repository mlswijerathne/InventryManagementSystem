import { useState, useEffect } from 'react';
import { dashboardApi, salesApi, productsApi } from '../api';
import { 
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';
import Alert from '../components/Alert';

// Register ChartJS components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

export default function ReportsPage() {
  const [salesByCategory, setSalesByCategory] = useState([]);
  const [topSellingProducts, setTopSellingProducts] = useState([]);
  const [lowStockProducts, setLowStockProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [retryCount, setRetryCount] = useState(0);

  useEffect(() => {
    const fetchReportData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch each report separately instead of using Promise.all
        // This prevents one slow endpoint from affecting others
        try {
          const salesByCategoryRes = await dashboardApi.getSalesByCategory();
          if (salesByCategoryRes.data?.success) {
            setSalesByCategory(salesByCategoryRes.data.data || []);
          }
        } catch (err) {
          console.error('Sales by category fetch error:', err);
          // Continue with other requests even if this one fails
        }
        
        try {
          const topSellingRes = await dashboardApi.getTopSelling();
          if (topSellingRes.data?.success) {
            setTopSellingProducts(topSellingRes.data.data || []);
          }
        } catch (err) {
          console.error('Top selling products fetch error:', err);
          // Continue with other requests even if this one fails
        }
        
        try {
          const lowStockRes = await dashboardApi.getLowStock();
          if (lowStockRes.data?.success) {
            setLowStockProducts(lowStockRes.data.data || []);
          }
        } catch (err) {
          console.error('Low stock products fetch error:', err);
          // Continue with other requests even if this one fails
        }
        
        // Check if we have at least some data
        if (salesByCategory.length === 0 && topSellingProducts.length === 0 && lowStockProducts.length === 0) {
          throw new Error('No report data could be retrieved');
        }
      } catch (err) {
        console.error('Report data fetch error:', err);
        
        // Set appropriate error message based on the error type
        if (err.code === 'ECONNABORTED') {
          setError('Request timed out. The server might be busy. Please try again later.');
        } else if (err.message.includes('Network Error')) {
          setError('Network error. Please check your connection and try again.');
        } else {
          setError('Failed to load report data. Please try again later.');
        }
        
        // Keep any data we successfully loaded
      } finally {
        setLoading(false);
      }
    };

    fetchReportData();
  }, [retryCount]);
  
  // Add a retry button for user to manually retry
  const handleRetry = () => {
    setRetryCount(prevCount => prevCount + 1);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }
  // Complete error - no data available
  if (error && salesByCategory.length === 0 && topSellingProducts.length === 0 && lowStockProducts.length === 0) {
    return (
      <div className="p-4">
        <div className="flex items-center justify-center h-full">
          <p className="text-gray-500">No report data available</p>
        </div>
      </div>
    );
  }

  // Prepare data for sales by category chart
  const salesByCategoryData = {
    labels: salesByCategory.map(item => item.category_name),
    datasets: [
      {
        label: 'Sales Amount',
        data: salesByCategory.map(item => item.total_sales),
        backgroundColor: 'rgba(75, 192, 192, 0.6)',
      },
    ],
  };

  // Prepare data for top selling products chart
  const topSellingData = {
    labels: topSellingProducts.map(item => item.product_name),
    datasets: [
      {
        label: 'Units Sold',
        data: topSellingProducts.map(item => item.total_quantity_sold),
        backgroundColor: 'rgba(54, 162, 235, 0.6)',
      },
    ],
  };

  return (
    <div className="space-y-8 p-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900">Reports</h1>
        <p className="mt-1 text-sm text-gray-500">
          View sales and inventory analysis reports
        </p>
      </div>      {/* No error messages shown as requested */}

      {/* Sales by Category */}
      {salesByCategory.length > 0 ? (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-medium mb-4">Sales by Category</h2>
          <div className="h-80">
            <Bar
              data={salesByCategoryData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                  y: {
                    beginAtZero: true,
                    title: {
                      display: true,
                      text: 'Total Sales ($)'
                    }
                  }
                },
                plugins: {
                  legend: {
                    display: false
                  },
                  title: {
                    display: false
                  }
                }
              }}
            />
          </div>
        </div>
      ) : !loading && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-medium mb-4">Sales by Category</h2>
          <div className="h-80 flex items-center justify-center">
            <p className="text-gray-500">Sales by category data is not available</p>
          </div>
        </div>
      )}

      {/* Top Selling Products */}
      {topSellingProducts.length > 0 ? (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-medium mb-4">Top Selling Products</h2>
          <div className="h-80">
            <Bar
              data={topSellingData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                scales: {
                  x: {
                    beginAtZero: true,
                    title: {
                      display: true,
                      text: 'Units Sold'
                    }
                  }
                },
                plugins: {
                  legend: {
                    display: false
                  }
                }
              }}
            />
          </div>
        </div>
      ) : !loading && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-medium mb-4">Top Selling Products</h2>
          <div className="h-80 flex items-center justify-center">
            <p className="text-gray-500">Top selling products data is not available</p>
          </div>
        </div>
      )}

      {/* Low Stock Products */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-medium mb-4">Low Stock Products</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Product
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Category
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Current Stock
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reorder Level
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {lowStockProducts.length > 0 ? (
                lowStockProducts.map((product) => (
                  <tr key={product.product_id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {product.product_name || product.name}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {product.category_name}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {product.quantity}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {product.reorder_level}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        product.quantity === 0 
                          ? 'bg-red-100 text-red-800' 
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {product.quantity === 0 ? 'Out of Stock' : 'Low Stock'}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="px-6 py-4 text-center text-sm text-gray-500">
                    No low stock products found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>      {/* Refresh button removed as requested */}
    </div>
  );
}
