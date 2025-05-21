'''
Dashboard controller for the Inventory Management System
'''
from flask import Blueprint, jsonify
from models.product import Product
from models.sale import Sale
from models import query_db

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/test', methods=['GET'])
def test_route():
    '''Test route'''
    return jsonify({'success': True, 'message': 'Dashboard controller is working'})

@dashboard_bp.route('/top-selling', methods=['GET'])
def get_top_selling():
    '''Get top selling products for dashboard'''
    try:
        # Query directly for better performance
        products = query_db("""
            SELECT TOP 5
                p.product_id,
                p.name AS product_name,
                c.name AS category_name,
                SUM(s.quantity) AS total_quantity_sold,
                SUM(s.quantity * s.sale_price) AS total_sales_amount
            FROM 
                sale s
            JOIN 
                product p ON s.product_id = p.product_id
            JOIN 
                category c ON p.category_id = c.category_id
            GROUP BY 
                p.product_id, p.name, c.name
            ORDER BY 
                SUM(s.quantity) DESC
        """)
        
        print(f'Top selling API returning {len(products) if products else 0} products')
        return jsonify({'success': True, 'data': products}), 200
    except Exception as e:
        print(f'Top selling API error: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@dashboard_bp.route('/low-stock', methods=['GET'])
def get_low_stock():
    '''Get low stock products for dashboard'''
    try:
        print("Low stock API endpoint called")
        # Get low stock products directly from the Product model
        products = Product.get_low_stock()
        
        # If products is None, initialize as empty list
        if products is None:
            products = []
            
        print(f'Low stock API returning {len(products)} products')
        return jsonify({'success': True, 'data': products}), 200
    except Exception as e:
        print(f'Low stock API error: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@dashboard_bp.route('/sales-by-category', methods=['GET'])
def get_sales_by_category():
    '''Get sales by category for dashboard'''
    try:
        # Use a simpler query with a limit to improve performance
        sales = query_db("""
            SELECT TOP 10
                c.name AS category_name,
                SUM(s.quantity) AS total_quantity_sold,
                SUM(s.quantity * s.sale_price) AS total_sales
            FROM 
                sale s
            JOIN 
                product p ON s.product_id = p.product_id
            JOIN 
                category c ON p.category_id = c.category_id
            GROUP BY 
                c.name
            ORDER BY 
                SUM(s.quantity * s.sale_price) DESC
        """)
        
        return jsonify({'success': True, 'data': sales}), 200
    except Exception as e:
        print(f'Sales by category API error: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@dashboard_bp.route('/overview', methods=['GET'])
def get_dashboard_overview():
    '''Get dashboard overview data'''
    try:
        # Get inventory summary
        inventory_summary = Product.get_inventory_summary()
        print(f"Inventory summary: {inventory_summary}")
        
        # Get low stock products
        low_stock = Product.get_low_stock()
        print(f"Low stock products count: {len(low_stock) if low_stock else 0}")
        
        # Get top selling products
        top_selling = Sale.get_top_selling_products(5)
        print(f"Top selling products count: {len(top_selling) if top_selling else 0}")
        
        # Get sales by category
        sales_by_category = Sale.get_sales_by_category()
        print(f"Sales by category count: {len(sales_by_category) if sales_by_category else 0}")
        
        # Ensure all data components are lists, not None
        if low_stock is None:
            low_stock = []
        if top_selling is None:
            top_selling = []
        if sales_by_category is None:
            sales_by_category = []
        
        # Combine all data for dashboard
        dashboard_data = {
            'inventory_summary': inventory_summary,
            'low_stock': low_stock,
            'top_selling': top_selling,
            'sales_by_category': sales_by_category
        }
        
        print(f"Dashboard overview complete, returning data")
        return jsonify({'success': True, 'data': dashboard_data}), 200
    except Exception as e:
        print(f'Dashboard overview error: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@dashboard_bp.route('/inventory-summary', methods=['GET'])
def get_inventory_summary():
    '''Get inventory summary for dashboard'''
    try:
        summary = Product.get_inventory_summary()
        return jsonify({'success': True, 'data': summary}), 200
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
