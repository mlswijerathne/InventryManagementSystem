"""
Category model for the Inventory Management System
"""
from models import query_db, execute_db

class Category:
    """Category model class"""

    
    @staticmethod
    def get_all():
        """Get all categories"""
        return query_db("""
            SELECT 
                c.category_id, 
                c.name, 
                c.description,
                COUNT(p.product_id) AS product_count
            FROM category c
            LEFT JOIN product p ON c.category_id = p.category_id
            GROUP BY c.category_id, c.name, c.description
            ORDER BY c.name
        """)
    


    @staticmethod
    def get_by_id(category_id):
        """Get a category by ID"""
        return query_db("""
            SELECT 
                c.category_id, 
                c.name, 
                c.description,
                (SELECT COUNT(*) FROM product WHERE category_id = c.category_id) AS product_count
            FROM category c
            WHERE c.category_id = ?
        """, [category_id], True)



    @staticmethod
    def create(name, description):
        """Create a new category"""
        # Check if category with the same name already exists
        existing = query_db("SELECT category_id FROM category WHERE name = ?", [name], True)
        if existing:
            raise ValueError(f"A category with the name '{name}' already exists")
            
        return execute_db("""
            INSERT INTO category (name, description)
            VALUES (?, ?)
        """, [name, description])



    @staticmethod
    def update(category_id, name, description):
        """Update a category"""
        # Check if another category with the same name already exists
        existing = query_db("""
            SELECT category_id FROM category 
            WHERE name = ? AND category_id != ?
        """, [name, category_id], True)
        
        if existing:
            raise ValueError(f"Another category with the name '{name}' already exists")
            
        execute_db("""
            UPDATE category
            SET name = ?, description = ?
            WHERE category_id = ?
        """, [name, description, category_id])
        return category_id


    
    @staticmethod
    def delete(category_id):
        """Delete a category"""
        execute_db("DELETE FROM category WHERE category_id = ?", [category_id])
        return category_id
    
    @staticmethod
    def get_with_products(category_id):
        """Get a category with its products"""
        try:
            category = Category.get_by_id(category_id)
            if not category:
                return None
            
            products = query_db("""
                SELECT 
                    p.product_id, 
                    p.name, 
                    p.price, 
                    p.quantity, 
                    p.reorder_level,
                    CASE 
                        WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
                        WHEN p.quantity = 0 THEN 'Out of Stock'
                        ELSE 'In Stock'
                    END AS stock_status
                FROM product p
                WHERE p.category_id = ?
                ORDER BY p.name
            """, [category_id])
            
            category['products'] = products
            return category
        except Exception as e:
            print(f"Error in get_with_products: {str(e)}")
            raise
