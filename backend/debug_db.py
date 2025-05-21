"""
Debug script to check database views and low stock products
"""
import pyodbc
import config

def get_db_connection():
    """Create a connection to the database"""
    # Connect to SQL Server with Windows Authentication or credentials
    if config.DB_TRUSTED_CONNECTION:
        conn_str = (
            f"DRIVER={{{config.DB_DRIVER}}};"
            f"SERVER={config.DB_SERVER};"
            f"DATABASE={config.DB_NAME};"
            f"Trusted_Connection=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={{{config.DB_DRIVER}}};"
            f"SERVER={config.DB_SERVER};"
            f"DATABASE={config.DB_NAME};"
            f"UID={config.DB_USER};"
            f"PWD={config.DB_PASSWORD};"
        )
    
    try:
        conn = pyodbc.connect(conn_str)
        conn.autocommit = True
        return conn
    except pyodbc.Error as e:
        print(f"Database connection error: {str(e)}")
        raise

def execute_query(conn, query, params=None, one=False):
    """Execute SQL query and return results as dictionaries"""
    cursor = conn.cursor()
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        # Convert to dictionaries
        columns = [column[0] for column in cursor.description]
        result = []
        
        rows = cursor.fetchall() if not one else [cursor.fetchone()]
        for row in rows:
            if row:  # Skip None results
                result.append(dict(zip(columns, row)))
        
        return result[0] if one and result else result
    finally:
        cursor.close()

def main():
    """Main debug function"""
    try:
        # Connect to database
        conn = get_db_connection()
        print("Database connection successful")
        
        # Check if the view exists
        view_check = execute_query(conn, """
            SELECT COUNT(*) AS view_count 
            FROM INFORMATION_SCHEMA.VIEWS 
            WHERE TABLE_NAME = 'view_low_stock'
        """, one=True)
        
        print(f"View low_stock exists: {view_check['view_count'] > 0}")
        
        # Check if there's any low stock products using direct query
        low_stock = execute_query(conn, """
            SELECT 
                p.product_id,
                p.name AS product_name,
                c.name AS category_name,
                p.quantity,
                p.reorder_level,
                p.price
            FROM 
                product p
            JOIN 
                category c ON p.category_id = c.category_id
            WHERE 
                p.quantity <= p.reorder_level
        """)
        
        print(f"Low stock products (direct query): {len(low_stock)}")
        for product in low_stock:
            print(f"  - {product['product_name']}: {product['quantity']} in stock, reorder at {product['reorder_level']}")
        
        # Try querying the view if it exists
        if view_check['view_count'] > 0:
            view_results = execute_query(conn, "SELECT * FROM view_low_stock")
            print(f"\nLow stock products (view query): {len(view_results)}")
            if not view_results:
                print("  - No results from view")
        
        # Check if there are any products at all
        products_count = execute_query(conn, "SELECT COUNT(*) AS count FROM product", one=True)
        print(f"\nTotal products in database: {products_count['count']}")
        
        # Check product quantities and reorder levels
        product_stats = execute_query(conn, """
            SELECT TOP 10
                p.product_id,
                p.name AS product_name,
                p.quantity,
                p.reorder_level,
                CASE 
                    WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
                    WHEN p.quantity = 0 THEN 'Out of Stock'
                    ELSE 'In Stock'
                END AS stock_status
            FROM product p
            ORDER BY p.quantity
        """)
        
        print("\nProduct quantities (lowest 10):")
        for product in product_stats:
            print(f"  - {product['product_name']}: {product['quantity']} in stock, reorder at {product['reorder_level']}, status: {product['stock_status']}")
    
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
