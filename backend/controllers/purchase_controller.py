"""
Purchase controller for the Inventory Management System
"""
from flask import Blueprint, jsonify, request
from models.purchase import Purchase
from services.stock_service import StockService
import config

purchase_bp = Blueprint('purchase', __name__)


@purchase_bp.route('/', methods=['GET'])
def get_all_purchases():
    """Get all purchases"""
    try:
        purchases = Purchase.get_all()
        return jsonify({"success": True, "data": purchases}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@purchase_bp.route('/<int:purchase_id>', methods=['GET'])
def get_purchase(purchase_id):
    """Get a purchase by ID"""
    try:
        purchase = Purchase.get_by_id(purchase_id)
        if not purchase:
            return jsonify({"success": False, "error": "Purchase not found"}), 404
        return jsonify({"success": True, "data": purchase}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@purchase_bp.route('/', methods=['POST'])
def create_purchase():
    """Create a new purchase"""
    try:
        data = request.get_json()
        # Validate input data
        if not all(k in data for k in ["product_id", "quantity", "purchase_price"]):
            return jsonify({"success": False, "error": "Missing required fields"}), 400
        product_id = data.get('product_id')
        quantity = data.get('quantity')
        purchase_price = data.get('purchase_price')
        supplier = data.get('supplier')
        
        # Validate numeric values
        if not isinstance(quantity, (int, float)) or quantity <= 0:
            return jsonify({"success": False, "error": "Quantity must be a positive number"}), 400
        
        if not isinstance(purchase_price, (int, float)) or purchase_price <= 0:
            return jsonify({"success": False, "error": "Purchase price must be a positive number"}), 400
        
        # Create purchase using stock service
        try:
            purchase_id = StockService.add_purchase(
                product_id, 
                quantity, 
                purchase_price, 
                supplier
            )
            
            return jsonify({
                "success": True, 
                "message": "Purchase recorded successfully and product price updated", 
                "purchase_id": purchase_id
            }), 201
        except Exception as e:
            return jsonify({"success": False, "error": f"Database error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@purchase_bp.route('/product/<int:product_id>', methods=['GET'])
def get_purchases_by_product(product_id):
    """Get purchases for a specific product"""
    try:
        purchases = Purchase.get_by_product(product_id)
        return jsonify({"success": True, "data": purchases}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@purchase_bp.route('/recent', methods=['GET'])
def get_recent_purchases():
    """Get recent purchases"""
    try:
        limit = request.args.get('limit', 10, type=int)
        purchases = Purchase.get_recent(limit)
        return jsonify({"success": True, "data": purchases}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
