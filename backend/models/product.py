"""
Product model for the Inventory Management System
"""
from models import query_db, execute_db

class Product:
    """Product model class"""
    
    @staticmethod
    def get_all():
        """Get all products with their categories"""
        return query_db("""
            SELECT 
                p.product_id, 
                p.name, 
                p.price, 
                p.base_price,
                p.quantity, 
                p.reorder_level,
                p.profit_percentage,
                c.name AS category_name,
                c.category_id,
                CASE 
                    WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
                    WHEN p.quantity = 0 THEN 'Out of Stock'
                    ELSE 'In Stock'
                END AS stock_status
            FROM product p
            JOIN category c ON p.category_id = c.category_id
            ORDER BY p.name
        """)
    
    @staticmethod
    def get_by_id(product_id):
        """Get a product by ID"""
        return query_db("""
            SELECT 
                p.product_id, 
                p.name, 
                p.price, 
                p.base_price,
                p.quantity, 
                p.reorder_level,
                p.profit_percentage,
                c.name AS category_name,
                c.category_id,
                CASE 
                    WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
                    WHEN p.quantity = 0 THEN 'Out of Stock'
                    ELSE 'In Stock'
                END AS stock_status,
                (SELECT ISNULL(SUM(quantity * sale_price), 0) FROM sale WHERE product_id = p.product_id) AS total_sales,
                (SELECT CASE 
                    WHEN AVG(purchase_price) IS NULL OR AVG(purchase_price) = 0 THEN 0
                    ELSE ((SELECT AVG(sale_price) FROM sale WHERE product_id = p.product_id) - AVG(purchase_price)) / AVG(purchase_price) * 100
                 END FROM purchase WHERE product_id = p.product_id) AS profit_margin
            FROM product p
            JOIN category c ON p.category_id = c.category_id
            WHERE p.product_id = ?
        """, [product_id], True)
    
    @staticmethod
    def get_low_stock():
        """Get products with low stock"""
        try:
            # Use a direct query instead of view for more reliability
            results = query_db("""
                SELECT 
                    p.product_id,
                    p.name AS product_name,
                    c.name AS category_name,
                    p.quantity,
                    p.reorder_level,
                    p.price,
                    p.base_price
                FROM 
                    product p
                JOIN 
                    category c ON p.category_id = c.category_id
                WHERE 
                    p.quantity <= p.reorder_level
                ORDER BY 
                    (p.reorder_level - p.quantity) DESC
            """)
            
            print(f"Low stock query returned {len(results) if results else 0} items")
            
            # If we got None instead of an empty list, return empty list
            if results is None:
                print("Query returned None, converting to empty list")
                return []
                
            return results
        except Exception as e:
            print(f"Error in get_low_stock: {str(e)}")
            import traceback
            traceback.print_exc()
            return []
    @staticmethod
    def create(name, category_id, price=0, quantity=0, reorder_level=10, profit_percentage=30):
        """Create a new product"""
        # Calculate base price (price without profit)
        base_price = price / (1 + (profit_percentage / 100)) if price > 0 else 0
        
        return execute_db("""
            INSERT INTO product (name, category_id, price, base_price, quantity, reorder_level, profit_percentage)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, [name, category_id, price, base_price, quantity, reorder_level, profit_percentage])
    @staticmethod
    def update(product_id, name, category_id, price=0, quantity=0, reorder_level=10, profit_percentage=None, base_price=None):
        """Update a product"""
        # Get existing product data if profit_percentage is not provided
        if profit_percentage is None:
            product = Product.get_by_id(product_id)
            if product:
                profit_percentage = product.get('profit_percentage', 30)
            else:
                profit_percentage = 30
        
        # If base_price is provided, use it
        if base_price is None:
            # Calculate base price (price without profit)
            base_price = price / (1 + (profit_percentage / 100)) if price > 0 else 0
        
        execute_db("""
            UPDATE product
            SET name = ?, 
                category_id = ?, 
                price = ?,
                base_price = ?,
                quantity = ?, 
                reorder_level = ?,
                profit_percentage = ?,
                updated_at = GETDATE()
            WHERE product_id = ?
        """, [name, category_id, price, base_price, quantity, reorder_level, profit_percentage, product_id])
        return product_id
        
    @staticmethod
    def check_product_references(product_id):
        """Check if a product has references in other tables"""
        purchase_refs = query_db("SELECT COUNT(*) AS count FROM purchase WHERE product_id = ?", [product_id], True)
        sale_refs = query_db("SELECT COUNT(*) AS count FROM sale WHERE product_id = ?", [product_id], True)
        
        return {
            'purchase_count': purchase_refs['count'] if purchase_refs else 0,
            'sale_count': sale_refs['count'] if sale_refs else 0,
            'has_references': (purchase_refs['count'] > 0 or sale_refs['count'] > 0) if purchase_refs and sale_refs else False
        }
        
    @staticmethod
    def delete(product_id):
        """Delete a product"""
        # Check for references first
        references = Product.check_product_references(product_id)
        
        if references['has_references']:
            error_msg = f"Cannot delete product with ID {product_id} because it has references: "
            error_msg += f"{references['purchase_count']} purchase records, {references['sale_count']} sale records"
            raise ValueError(error_msg)
            
        execute_db("DELETE FROM product WHERE product_id = ?", [product_id])
        return product_id

    @staticmethod
    def get_top_selling(limit=5):
        """Get top selling products"""
        return query_db("""
            SELECT TOP (?) * FROM view_top_selling_products
        """, [limit])
    
    @staticmethod
    def get_inventory_summary():
        """Get inventory summary"""
        total_value = query_db("SELECT SUM(quantity * price) AS total_value FROM product", one=True)
        total_items = query_db("SELECT SUM(quantity) AS total_items FROM product", one=True)
        products_count = query_db("SELECT COUNT(*) AS product_count FROM product", one=True)
        low_stock_count = query_db("SELECT COUNT(*) AS low_stock_count FROM view_low_stock", one=True)
        
        return {
            "total_value": total_value['total_value'] if total_value else 0,
            "total_items": total_items['total_items'] if total_items else 0,
            "products_count": products_count['product_count'] if products_count else 0,
            "low_stock_count": low_stock_count['low_stock_count'] if low_stock_count else 0
        }
