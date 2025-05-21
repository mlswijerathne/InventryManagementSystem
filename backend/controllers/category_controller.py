"""
Category controller for the Inventory Management System
"""
from flask import Blueprint, jsonify, request
from models.category import Category
from models import query_db

category_bp = Blueprint('category', __name__)


@category_bp.route('/', methods=['GET'])
def get_all_categories():
    """Get all categories"""
    try:
        categories = Category.get_all()
        return jsonify({"success": True, "data": categories}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@category_bp.route('/<int:category_id>', methods=['GET'])
def get_category(category_id):
    """Get a category by ID"""
    try:
        category = Category.get_by_id(category_id)
        if not category:
            return jsonify({"success": False, "error": "Category not found"}), 404
        return jsonify({"success": True, "data": category}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@category_bp.route('/', methods=['POST'])
def create_category():
    """Create a new category"""
    try:
        data = request.get_json()
        # Validate input data
        if not "name" in data:
            return jsonify({"success": False, "error": "Missing required field: name"}), 400
        
        name = data.get('name')
        description = data.get('description', '')
        
        # Create category
        try:
            category_id = Category.create(name, description)
            return jsonify({
                "success": True, 
                "message": "Category created successfully", 
                "category_id": category_id
            }), 201
        except ValueError as ve:
            return jsonify({"success": False, "error": str(ve)}), 400
            
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@category_bp.route('/<int:category_id>', methods=['PUT'])
def update_category(category_id):
    """Update a category"""
    try:
        data = request.get_json()
        # Validate input data
        if not "name" in data:
            return jsonify({"success": False, "error": "Missing required field: name"}), 400
        
        # Check if category exists
        category = Category.get_by_id(category_id)
        if not category:
            return jsonify({"success": False, "error": "Category not found"}), 404
        
        name = data.get('name')
        description = data.get('description', category.get('description', ''))
        
        # Update category
        try:
            Category.update(category_id, name, description)
            return jsonify({
                "success": True, 
                "message": "Category updated successfully"
            }), 200
        except ValueError as ve:
            return jsonify({"success": False, "error": str(ve)}), 400
            
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500



@category_bp.route('/<int:category_id>', methods=['DELETE'])
def delete_category(category_id):
    """Delete a category"""
    try:
        # Check if category exists
        category = Category.get_by_id(category_id)
        if not category:
            return jsonify({"success": False, "error": "Category not found"}), 404
        
        # Check if category has products
        if category.get('product_count', 0) > 0:
            return jsonify({
                "success": False, 
                "error": "Cannot delete category with associated products"
            }), 400
        
        # Delete category
        Category.delete(category_id)
        
        return jsonify({
            "success": True, 
            "message": "Category deleted successfully"
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

        

@category_bp.route('/<int:category_id>/products', methods=['GET'])
def get_category_products(category_id):
    """Get products in a category"""
    try:
        print(f"Fetching products for category ID: {category_id}")
        category = Category.get_with_products(category_id)
        if not category:
            print(f"Category not found: {category_id}")
            return jsonify({"success": False, "error": "Category not found"}), 404
        print(f"Found category: {category['name']} with {len(category['products'])} products")
        return jsonify({"success": True, "data": category}), 200
    except Exception as e:
        print(f"Error in get_category_products: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500


@category_bp.route('/test-connection', methods=['GET'])
def test_category_connection():
    """Test database connection from category controller"""
    try:
        # Try to execute a simple query
        categories = query_db("SELECT TOP 1 * FROM category")
        return jsonify({
            "success": True, 
            "message": "Database connection is working correctly",
            "data": categories
        }), 200
    except Exception as e:
        print(f"Database connection test error: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
