"""
Product controller for the Inventory Management System
"""
from flask import Blueprint, jsonify, request
from models.product import Product

product_bp = Blueprint('product', __name__)



@product_bp.route('/', methods=['GET'])
def get_all_products():
    """Get all products"""
    try:
        products = Product.get_all()
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get a product by ID"""
    try:
        product = Product.get_by_id(product_id)
        if not product:
            return jsonify({"success": False, "error": "Product not found"}), 404
        return jsonify({"success": True, "data": product}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/', methods=['POST'])
def create_product():
    """Create a new product"""
    try:
        data = request.get_json()
        # Validate input data
        if not all(k in data for k in ["name", "category_id", "price"]):
            return jsonify({"success": False, "error": "Missing required fields"}), 400
        
        name = data.get('name')
        category_id = data.get('category_id')
        price = data.get('price')
        quantity = data.get('quantity', 0)
        reorder_level = data.get('reorder_level', 10)
        
        # Create product
        product_id = Product.create(name, category_id, price, quantity, reorder_level)
        
        return jsonify({
            "success": True, 
            "message": "Product created successfully", 
            "product_id": product_id
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update a product"""
    try:
        data = request.get_json()
        # Validate input data
        if not all(k in data for k in ["name", "category_id", "price"]):
            return jsonify({"success": False, "error": "Missing required fields"}), 400
        
        # Check if product exists
        product = Product.get_by_id(product_id)
        if not product:
            return jsonify({"success": False, "error": "Product not found"}), 404
        
        name = data.get('name')
        category_id = data.get('category_id')
        price = data.get('price')
        quantity = data.get('quantity', product.get('quantity', 0))
        reorder_level = data.get('reorder_level', product.get('reorder_level', 10))
        
        # Update product
        Product.update(product_id, name, category_id, price, quantity, reorder_level)
        
        return jsonify({
            "success": True, 
            "message": "Product updated successfully"
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete a product"""
    try:
        # Check if product exists
        product = Product.get_by_id(product_id)
        if not product:
            return jsonify({"success": False, "error": "Product not found"}), 404
        
        # Delete product
        Product.delete(product_id)
        
        return jsonify({
            "success": True, 
            "message": "Product deleted successfully"
        }), 200
    except ValueError as e:
        # Handle specific value error that we raise when product has references
        return jsonify({"success": False, "error": str(e)}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/low-stock', methods=['GET'])
def get_low_stock():
    """Get products with low stock"""
    try:
        products = Product.get_low_stock()
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        print(f"Low stock API error: {str(e)}")  # Add logging for debugging
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/top-selling', methods=['GET'])
def get_top_selling():
    """Get top selling products"""
    try:
        limit = request.args.get('limit', 5, type=int)
        products = Product.get_top_selling(limit)
        return jsonify({"success": True, "data": products}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@product_bp.route('/inventory-summary', methods=['GET'])
def get_inventory_summary():
    """Get inventory summary"""
    try:
        summary = Product.get_inventory_summary()
        return jsonify({"success": True, "data": summary}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
