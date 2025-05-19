"""
Sale controller for the Inventory Management System
"""
from flask import Blueprint, jsonify, request
from models.sale import Sale

sale_bp = Blueprint('sale', __name__)

@sale_bp.route('/', methods=['GET'])
def get_all_sales():
    """Get all sales"""
    try:
        sales = Sale.get_all()
        return jsonify({"success": True, "data": sales}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@sale_bp.route('/<int:sale_id>', methods=['GET'])
def get_sale(sale_id):
    """Get a sale by ID"""
    try:
        sale = Sale.get_by_id(sale_id)
        if not sale:
            return jsonify({"success": False, "error": "Sale not found"}), 404
        return jsonify({"success": True, "data": sale}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@sale_bp.route('/', methods=['POST'])
def create_sale():
    """Create a new sale"""
    try:
        data = request.get_json()
        # Validate input data
        if not all(k in data for k in ["product_id", "quantity", "sale_price"]):
            return jsonify({"success": False, "error": "Missing required fields"}), 400
        
        product_id = data.get('product_id')
        quantity = data.get('quantity')
        sale_price = data.get('sale_price')
        
        # Validate numeric values
        if not isinstance(quantity, (int, float)) or quantity <= 0:
            return jsonify({"success": False, "error": "Quantity must be a positive number"}), 400
        
        if not isinstance(sale_price, (int, float)) or sale_price <= 0:
            return jsonify({"success": False, "error": "Sale price must be a positive number"}), 400
        
        # Create sale using stored procedure
        try:
            sale_id = Sale.create(product_id, quantity, sale_price)
            
            return jsonify({
                "success": True, 
                "message": "Sale recorded successfully", 
                "sale_id": sale_id
            }), 201
        except Exception as e:
            # This could be a stock level error from the stored procedure
            return jsonify({"success": False, "error": f"Database error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@sale_bp.route('/product/<int:product_id>', methods=['GET'])
def get_sales_by_product(product_id):
    """Get sales for a specific product"""
    try:
        sales = Sale.get_by_product(product_id)
        return jsonify({"success": True, "data": sales}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@sale_bp.route('/recent', methods=['GET'])
def get_recent_sales():
    """Get recent sales"""
    try:
        limit = request.args.get('limit', 10, type=int)
        sales = Sale.get_recent(limit)
        return jsonify({"success": True, "data": sales}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@sale_bp.route('/top-selling', methods=['GET'])
def get_top_selling():
    """Get top selling products"""
    try:
        limit = request.args.get('limit', 5, type=int)
        products = Sale.get_top_selling_products(limit)
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@sale_bp.route('/by-category', methods=['GET'])
def get_sales_by_category():
    """Get sales aggregated by category"""
    try:
        sales = Sale.get_sales_by_category()
        return jsonify({"success": True, "data": sales}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
