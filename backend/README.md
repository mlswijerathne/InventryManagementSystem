# Mini Inventory Management System

A simple inventory management system with real-time product tracking, stock updates, and a Business Intelligence dashboard using a MySQL database, Python Flask API, and a React.js frontend.

## Backend Setup

### Requirements

- Python 3.8+
- SQL Server
- Node.js and npm (for frontend)

### Database Setup

1. Create a database named `inventory_management` in SQL Server
2. Run the SQL scripts in the following order:
   - `database/schema.sql` - Creates tables
   - `database/functions.sql` - Creates SQL functions
   - `database/procedures.sql` - Creates stored procedures
   - `database/triggers.sql` - Creates triggers
   - `database/views.sql` - Creates views
   - `database/seed_data.sql` - Populates tables with sample data

You can run these scripts directly in SQL Server Management Studio or use the following PowerShell commands:

```powershell
sqlcmd -S your_server_name -d inventory_management -i database/schema.sql
sqlcmd -S your_server_name -d inventory_management -i database/functions.sql
sqlcmd -S your_server_name -d inventory_management -i database/procedures.sql
sqlcmd -S your_server_name -d inventory_management -i database/triggers.sql
sqlcmd -S your_server_name -d inventory_management -i database/views.sql
sqlcmd -S your_server_name -d inventory_management -i database/seed_data.sql
```

### Backend Installation

1. Create a virtual environment (optional but recommended):
   ```
   python -m venv venv
   .\venv\Scripts\activate
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Configure the database connection in `.env` file (create it if it doesn't exist):
   ```
   DB_SERVER=your_server_name
   DB_USER=your_username
   DB_PASSWORD=your_password
   DB_NAME=inventory_management
   DB_DRIVER=SQL Server
   DB_TRUSTED_CONNECTION=yes
   DEBUG=True
   ```

4. Run the Flask application:
   ```
   python app.py
   ```

The API will be available at `http://localhost:5000`

## API Endpoints

### Products

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create a new product
- `PUT /api/products/{id}` - Update a product
- `DELETE /api/products/{id}` - Delete a product
- `GET /api/products/low-stock` - Get products with low stock
- `GET /api/products/top-selling` - Get top selling products
- `GET /api/products/inventory-summary` - Get inventory summary

### Categories

- `GET /api/categories` - Get all categories
- `GET /api/categories/{id}` - Get category by ID
- `POST /api/categories` - Create a new category
- `PUT /api/categories/{id}` - Update a category
- `DELETE /api/categories/{id}` - Delete a category
- `GET /api/categories/{id}/products` - Get products in a category

### Purchases

- `GET /api/purchases` - Get all purchases
- `GET /api/purchases/{id}` - Get purchase by ID
- `POST /api/purchases` - Create a new purchase
- `GET /api/purchases/product/{id}` - Get purchases for a product
- `GET /api/purchases/recent` - Get recent purchases

### Sales

- `GET /api/sales` - Get all sales
- `GET /api/sales/{id}` - Get sale by ID
- `POST /api/sales` - Create a new sale
- `GET /api/sales/product/{id}` - Get sales for a product
- `GET /api/sales/recent` - Get recent sales
- `GET /api/sales/top-selling` - Get top selling products
- `GET /api/sales/by-category` - Get sales by category

### Dashboard

- `GET /api/dashboard/overview` - Get dashboard overview data
- `GET /api/dashboard/low-stock` - Get low stock products for dashboard
- `GET /api/dashboard/top-selling` - Get top selling products for dashboard
- `GET /api/dashboard/inventory-summary` - Get inventory summary for dashboard
- `GET /api/dashboard/sales-by-category` - Get sales by category for dashboard

## Project Structure

```
Inventory Management System/
│
├── backend/               # Flask application backend
│   ├── app.py             # Main Flask application
│   ├── config.py          # Configuration settings
│   ├── requirements.txt   # Python dependencies
│   │
│   ├── database/          # Database scripts
│   │   ├── schema.sql     # Database schema
│   │   ├── seed_data.sql  # Sample data
│   │   ├── views.sql      # SQL views
│   │   ├── triggers.sql   # SQL triggers
│   │   ├── procedures.sql # SQL procedures
│   │   └── functions.sql  # SQL functions
│   │
│   ├── models/            # Data models
│   │   ├── product.py     # Product model
│   │   ├── category.py    # Category model
│   │   ├── purchase.py    # Purchase model
│   │   └── sale.py        # Sale model
│   │
│   ├── controllers/       # API controllers
│   │   ├── product_controller.py
│   │   ├── category_controller.py
│   │   ├── purchase_controller.py
│   │   ├── sale_controller.py
│   │   └── dashboard_controller.py
│   │
│   ├── services/          # Business logic services
│   │   ├── product_service.py
│   │   ├── stock_service.py
│   │   └── analytics_service.py
│   │
│   └── utils/             # Utility functions
│       └── db_helper.py   # Database helpers
│
└── frontend/              # React.js frontend (to be created)
```

## Project Features

- **Product Management**: View and manage products
- **Stock Control**: Add purchases and sales to update inventory
- **Business Intelligence**: View low stock alerts, top selling products, and inventory value
- **Data Insights**: Analyze sales data and identify fast-moving items