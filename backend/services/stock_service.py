"""
Stock service for the Inventory Management System
"""
from models.purchase import Purchase
from models.sale import Sale
from models.product import Product
import config

class StockService:
    """Service for stock management operations"""
    @staticmethod
    def add_purchase(product_id, quantity, purchase_price, supplier=None):
        """
        Add a purchase to increase stock and update product price
        
        Args:
            product_id: ID of the product
            quantity: Quantity purchased
            purchase_price: Price per unit
            supplier: Optional supplier name
        
        Returns:
            purchase_id: ID of the newly created purchase
        """
        # Validate inputs
        if not isinstance(quantity, (int, float)) or quantity <= 0:
            raise ValueError("Quantity must be a positive number")
        
        if not isinstance(purchase_price, (int, float)) or purchase_price <= 0:
            raise ValueError("Purchase price must be a positive number")
        
        # Check if product exists
        product = Product.get_by_id(product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found")
        
        # Create purchase (the stored procedure will handle stock and price update using product's profit percentage)
        purchase_id = Purchase.create(product_id, quantity, purchase_price, supplier)
        
        return purchase_id
    
    @staticmethod
    def add_sale(product_id, quantity, sale_price):
        """
        Add a sale to decrease stock
        
        Args:
            product_id: ID of the product
            quantity: Quantity sold
            sale_price: Price per unit
        
        Returns:
            sale_id: ID of the newly created sale
        """
        # Validate inputs
        if not isinstance(quantity, (int, float)) or quantity <= 0:
            raise ValueError("Quantity must be a positive number")
        
        if not isinstance(sale_price, (int, float)) or sale_price <= 0:
            raise ValueError("Sale price must be a positive number")
        
        # Check if product exists
        product = Product.get_by_id(product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found")
        
        # Check if there's enough stock
        if product['quantity'] < quantity:
            raise ValueError(f"Not enough stock available. Current stock: {product['quantity']}, Requested: {quantity}")
        
        # Create sale (the stored procedure will handle stock update)
        sale_id = Sale.create(product_id, quantity, sale_price)
        
        return sale_id
    
    @staticmethod
    def get_recent_purchases(limit=10):
        """Get recent purchase transactions"""
        return Purchase.get_recent(limit)
    
    @staticmethod
    def get_recent_sales(limit=10):
        """Get recent sale transactions"""
        return Sale.get_recent(limit)
    
    @staticmethod
    def get_product_purchase_history(product_id):
        """Get purchase history for a specific product"""
        return Purchase.get_by_product(product_id)
    
    @staticmethod
    def get_product_sales_history(product_id):
        """Get sales history for a specific product"""
        return Sale.get_by_product(product_id)
