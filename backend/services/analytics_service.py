"""
Analytics service for the Inventory Management System
"""
from models.product import Product
from models.sale import Sale

class AnalyticsService:
    """Service for business intelligence and analytics operations"""
    
    @staticmethod
    def get_dashboard_data():
        """
        Get complete dashboard data including:
        - Inventory summary
        - Low stock products
        - Top selling products
        - Sales by category
        """
        # Get inventory summary
        inventory_summary = Product.get_inventory_summary()
        
        # Get low stock products
        low_stock = Product.get_low_stock()
        
        # Get top selling products
        top_selling = Sale.get_top_selling_products(5)
        
        # Get sales by category
        sales_by_category = Sale.get_sales_by_category()
        
        # Construct response object
        dashboard_data = {
            "inventory_summary": inventory_summary,
            "low_stock_products": low_stock,
            "top_selling_products": top_selling,
            "sales_by_category": sales_by_category
        }
        
        return dashboard_data
    
    @staticmethod
    def get_top_selling_products(limit=5):
        """Get top selling products by quantity sold"""
        return Sale.get_top_selling_products(limit)
    
    @staticmethod
    def get_low_stock_alerts():
        """Get products with stock levels at or below reorder point"""
        return Product.get_low_stock()
    
    @staticmethod
    def get_inventory_value():
        """Get total inventory value and counts"""
        return Product.get_inventory_summary()
    
    @staticmethod
    def get_sales_by_category():
        """Get sales data aggregated by product category"""
        return Sale.get_sales_by_category()
