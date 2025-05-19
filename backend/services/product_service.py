"""
Product service for the Inventory Management System
"""
from models.product import Product

class ProductService:
    """Service for product-related operations"""
    
    @staticmethod
    def get_all_products():
        """Get all products with their details"""
        return Product.get_all()
    
    @staticmethod
    def get_product_details(product_id):
        """Get detailed information about a specific product"""
        return Product.get_by_id(product_id)
    
    @staticmethod
    def create_product(name, category_id, price, quantity=0, reorder_level=10):
        """Create a new product"""
        return Product.create(name, category_id, price, quantity, reorder_level)
    
    @staticmethod
    def update_product(product_id, name, category_id, price, quantity, reorder_level):
        """Update an existing product"""
        return Product.update(product_id, name, category_id, price, quantity, reorder_level)
    
    @staticmethod
    def delete_product(product_id):
        """Delete a product"""
        return Product.delete(product_id)
    
    @staticmethod
    def get_low_stock_products():
        """Get products with stock levels at or below reorder level"""
        return Product.get_low_stock()
    
    @staticmethod
    def get_inventory_summary():
        """Get summary of inventory status"""
        return Product.get_inventory_summary()
