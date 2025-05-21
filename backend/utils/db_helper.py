"""
Database helper for the Inventory Management System
"""
import pyodbc
from flask import g
import config

def get_db_connection():
    """
    Create a connection to the database
    
    Returns:
        pyodbc.Connection: A connection to the database
    """
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

def setup_database_connection(app):
    """
    Setup database connection handlers for Flask app
    
    Args:
        app: Flask application instance
    """
    # Run the database migration procedure to ensure product pricing fields exist
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_ensure_product_pricing_fields")
        conn.commit()
        cursor.close()
        conn.close()
        print("Database schema migration completed successfully")
    except Exception as e:
        print(f"Error during database schema migration: {str(e)}")
    
    @app.before_request
    def before_request():
        """Create a database connection before each request"""
        g.db = get_db_connection()

    @app.teardown_request
    def teardown_request(exception):
        """Close the database connection after each request"""
        if hasattr(g, 'db'):
            g.db.close()

def test_database_connection():
    """
    Test the database connection
    
    Returns:
        bool: True if connection is successful, False otherwise
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 'Connection successful' AS message")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Database connection test failed: {str(e)}")
        return False

def execute_sql_script(script_path):
    """
    Execute an SQL script file
    
    Args:
        script_path: Path to the SQL script file
        
    Returns:
        bool: True if execution is successful, False otherwise
    """
    try:
        # Read the script file
        with open(script_path, 'r') as file:
            script = file.read()
        
        # Split the script by GO statements
        statements = script.split('GO')
        
        # Execute each statement
        conn = get_db_connection()
        cursor = conn.cursor()
        
        for statement in statements:
            if statement.strip():
                cursor.execute(statement)
        
        cursor.close()
        conn.close()
        
        return True
    except Exception as e:
        print(f"Error executing SQL script {script_path}: {str(e)}")
        return False
