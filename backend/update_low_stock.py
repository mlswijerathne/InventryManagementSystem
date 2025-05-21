"""
Script to update some products to have low stock
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

def execute_query(conn, query, params=None):
    """Execute SQL query and return affected rows"""
    cursor = conn.cursor()
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        return cursor.rowcount
    finally:
        cursor.close()

def main():
    """Main function to update product quantities"""
    try:
        # Connect to database
        conn = get_db_connection()
        print("Database connection successful")
        
        # Products to update to low stock
        products_to_update = [
            {"name": "Fingerprint Scanner", "quantity": 3},
            {"name": "Network Cable Tester", "quantity": 2},
            {"name": "Laptop Battery Replacement", "quantity": 4},
            {"name": "Document Scanner", "quantity": 0},
            {"name": "Mini Projector", "quantity": 3}
        ]
        
        # Update each product
        for product in products_to_update:
            rows = execute_query(
                conn,
                "UPDATE product SET quantity = ? WHERE name = ?",
                [product["quantity"], product["name"]]
            )
            print(f"Updated {product['name']} to quantity {product['quantity']}: {rows} rows affected")
        
        print("\nProducts updated successfully!")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
