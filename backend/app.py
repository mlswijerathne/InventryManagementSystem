from flask import Flask, jsonify, g
from flask_cors import CORS
import pyodbc
import os
import config
from utils.db_helper import setup_database_connection, test_database_connection
from controllers.product_controller import product_bp
from controllers.category_controller import category_bp
from controllers.purchase_controller import purchase_bp
from controllers.sale_controller import sale_bp
from controllers.dashboard_controller import dashboard_bp

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Set up database connection handlers
setup_database_connection(app)

# Register blueprints
app.register_blueprint(product_bp, url_prefix=f'{config.API_PREFIX}/products')
app.register_blueprint(category_bp, url_prefix=f'{config.API_PREFIX}/categories')
app.register_blueprint(purchase_bp, url_prefix=f'{config.API_PREFIX}/purchases')
app.register_blueprint(sale_bp, url_prefix=f'{config.API_PREFIX}/sales')
app.register_blueprint(dashboard_bp, url_prefix=f'{config.API_PREFIX}/dashboard')

# Test database connection route
@app.route('/test-connection')
def test_connection():
    try:
        cursor = g.db.cursor()
        cursor.execute("SELECT 'Connection successful' AS message")
        result = cursor.fetchone()
        cursor.close()
        return jsonify({"message": result[0]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Home route
@app.route('/')
def home():
    return jsonify({
        "message": "Welcome to the Inventory Management System API",
        "version": "1.0.0",
        "endpoints": {
            "products": f"{config.API_PREFIX}/products",
            "categories": f"{config.API_PREFIX}/categories",
            "purchases": f"{config.API_PREFIX}/purchases",
            "sales": f"{config.API_PREFIX}/sales",
            "dashboard": f"{config.API_PREFIX}/dashboard"
        }
    })

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config.PORT, debug=config.DEBUG)
