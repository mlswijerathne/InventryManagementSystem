"""
Sale model for the Inventory Management System
"""
from models import query_db, execute_db

class Sale:
    """Sale model class"""
    
    @staticmethod
    def get_all():
        """Get all sales"""
        return query_db("""
            SELECT 
                s.sale_id, 
                s.product_id, 
                p.name AS product_name,
                s.quantity, 
                s.sale_price,
                s.quantity * s.sale_price AS total_amount,
                s.sale_date
            FROM sale s
            JOIN product p ON s.product_id = p.product_id
            ORDER BY s.sale_date DESC
        """)
    
    @staticmethod
    def get_by_id(sale_id):
        """Get a sale by ID"""
        return query_db("""
            SELECT 
                s.sale_id, 
                s.product_id, 
                p.name AS product_name,
                s.quantity, 
                s.sale_price,
                s.quantity * s.sale_price AS total_amount,
                s.sale_date
            FROM sale s
            JOIN product p ON s.product_id = p.product_id
            WHERE s.sale_id = ?
        """, [sale_id], True)
    
    @staticmethod
    def create(product_id, quantity, sale_price):
        """Create a new sale using stored procedure"""
        return execute_db("""
            EXEC sp_make_sale ?, ?, ?
        """, [product_id, quantity, sale_price])
    
    @staticmethod
    def get_by_product(product_id):
        """Get sales for a specific product"""
        return query_db("""
            EXEC sp_get_product_sales_history ?
        """, [product_id])
    
    @staticmethod
    def get_recent(limit=10):
        """Get recent sales"""
        return query_db("""
            SELECT TOP (?) * FROM view_recent_sales
        """, [limit])
    
    @staticmethod
    def get_top_selling_products(limit=5):
        """Get top selling products"""
        return query_db("""
            SELECT TOP (?) * FROM view_top_selling_products
        """, [limit])
    
    @staticmethod
    def get_sales_by_category():
        """Get sales aggregated by category"""
        return query_db("""
            SELECT 
                c.name AS category_name,
                SUM(s.quantity) AS total_quantity_sold,
                SUM(s.quantity * s.sale_price) AS total_sales_value
            FROM 
                sale s
            JOIN 
                product p ON s.product_id = p.product_id
            JOIN 
                category c ON p.category_id = c.category_id
            GROUP BY 
                c.name
            ORDER BY 
                total_sales_value DESC
        """)
