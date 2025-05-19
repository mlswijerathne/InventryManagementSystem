"""
Dashboard controller for the Inventory Management System
"""
from flask import Blueprint, jsonify
from models.product import Product
from models.sale import Sale

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/overview', methods=['GET'])
def get_dashboard_overview():
    """Get dashboard overview data"""
    try:
        # Get inventory summary
        inventory_summary = Product.get_inventory_summary()
        
        # Get low stock products
        low_stock = Product.get_low_stock()
        
        # Get top selling products
        top_selling = Sale.get_top_selling_products(5)
        
        # Get sales by category
        sales_by_category = Sale.get_sales_by_category()
        
        # Combine all data for dashboard
        dashboard_data = {
            "inventory_summary": inventory_summary,
            "low_stock": low_stock,
            "top_selling": top_selling,
            "sales_by_category": sales_by_category
        }
        
        return jsonify({"success": True, "data": dashboard_data}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500





@dashboard_bp.route('/low-stock', methods=['GET'])
def get_low_stock():
    """Get low stock products for dashboard"""
    try:
        products = Product.get_low_stock()
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@dashboard_bp.route('/top-selling', methods=['GET'])
def get_top_selling():
    """Get top selling products for dashboard"""
    try:
        products = Sale.get_top_selling_products(5)
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@dashboard_bp.route('/inventory-summary', methods=['GET'])
def get_inventory_summary():
    """Get inventory summary for dashboard"""
    try:
        summary = Product.get_inventory_summary()
        return jsonify({"success": True, "data": summary}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@dashboard_bp.route('/sales-by-category', methods=['GET'])
def get_sales_by_category():
    """Get sales by category for dashboard"""
    try:
        sales = Sale.get_sales_by_category()
        return jsonify({"success": True, "data": sales}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
