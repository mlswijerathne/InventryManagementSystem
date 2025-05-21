"""
Purchase model for the Inventory Management System
"""
from models import query_db, execute_db
import config

class Purchase:
    """Purchase model class"""
    
    @staticmethod
    def get_all():
        """Get all purchases"""
        return query_db("""
            SELECT 
                pu.purchase_id, 
                pu.product_id, 
                p.name AS product_name,
                pu.quantity, 
                pu.purchase_price,
                pu.quantity * pu.purchase_price AS total_cost,
                pu.supplier,
                pu.purchase_date
            FROM purchase pu
            JOIN product p ON pu.product_id = p.product_id
            ORDER BY pu.purchase_date DESC
        """)
    
    @staticmethod
    def get_by_id(purchase_id):
        """Get a purchase by ID"""
        return query_db("""
            SELECT 
                pu.purchase_id, 
                pu.product_id, 
                p.name AS product_name,
                pu.quantity, 
                pu.purchase_price,
                pu.quantity * pu.purchase_price AS total_cost,
                pu.supplier,
                pu.purchase_date
            FROM purchase pu
            JOIN product p ON pu.product_id = p.product_id
            WHERE pu.purchase_id = ?
        """, [purchase_id], True)
    
    @staticmethod
    def create(product_id, quantity, purchase_price, supplier=None):
        """Create a new purchase using stored procedure with price update based on product's profit percentage"""
        return execute_db("""
            EXEC sp_add_purchase ?, ?, ?, ?
        """, [product_id, quantity, purchase_price, supplier])
    
    @staticmethod
    def get_by_product(product_id):
        """Get purchases for a specific product"""
        return query_db("""
            SELECT 
                pu.purchase_id, 
                pu.product_id, 
                p.name AS product_name,
                pu.quantity, 
                pu.purchase_price,
                pu.quantity * pu.purchase_price AS total_cost,
                pu.supplier,
                pu.purchase_date
            FROM purchase pu
            JOIN product p ON pu.product_id = p.product_id
            WHERE pu.product_id = ?
            ORDER BY pu.purchase_date DESC
        """, [product_id])
    
    @staticmethod
    def get_recent(limit=10):
        """Get recent purchases"""
        return query_db("""
            SELECT TOP (?) 
                pu.purchase_id, 
                pu.product_id, 
                p.name AS product_name,
                pu.quantity, 
                pu.purchase_price,
                pu.quantity * pu.purchase_price AS total_cost,
                pu.supplier,
                pu.purchase_date
            FROM purchase pu
            JOIN product p ON pu.product_id = p.product_id
            ORDER BY pu.purchase_date DESC
        """, [limit])
