-- Seed data for the inventory management system

USE inventory_management;
GO

-- Insert sample categories
INSERT INTO category (name, description)
VALUES 
    ('Electronics', 'Electronic devices and components'),
    ('Clothing', 'Apparel and accessories'),
    ('Home & Kitchen', 'Household items and kitchenware'),
    ('Office Supplies', 'Office stationary and supplies');
GO

-- Insert sample products
INSERT INTO product (name, category_id, price, quantity, reorder_level)
VALUES
    ('Laptop', 1, 899.99, 15, 5),
    ('Smartphone', 1, 499.99, 25, 8),
    ('Bluetooth Headphones', 1, 79.99, 30, 10),
    ('T-shirt', 2, 19.99, 50, 15),
    ('Jeans', 2, 49.99, 35, 10),
    ('Blender', 3, 59.99, 12, 5),
    ('Coffee Maker', 3, 89.99, 8, 3),
    ('Notebooks', 4, 4.99, 100, 20),
    ('Pens (Pack of 10)', 4, 7.99, 75, 15);
GO

-- Insert sample purchases
INSERT INTO purchase (product_id, quantity, purchase_price, supplier, purchase_date)
VALUES
    (1, 5, 800.00, 'Tech Wholesale Inc.', DATEADD(day, -30, GETDATE())),
    (2, 10, 450.00, 'Mobile Supplies Ltd.', DATEADD(day, -25, GETDATE())),
    (3, 15, 65.00, 'Audio Experts', DATEADD(day, -20, GETDATE())),
    (4, 20, 15.00, 'Fashion Distributors', DATEADD(day, -15, GETDATE())),
    (5, 15, 40.00, 'Fashion Distributors', DATEADD(day, -15, GETDATE())),
    (6, 5, 50.00, 'HomeGoods Supply', DATEADD(day, -10, GETDATE())),
    (7, 3, 75.00, 'HomeGoods Supply', DATEADD(day, -10, GETDATE())),
    (8, 30, 3.50, 'Office Depot', DATEADD(day, -5, GETDATE())),
    (9, 25, 6.00, 'Office Depot', DATEADD(day, -5, GETDATE()));
GO

-- Insert sample sales
INSERT INTO sale (product_id, quantity, sale_price, sale_date)
VALUES
    (1, 2, 899.99, DATEADD(day, -20, GETDATE())),
    (2, 5, 499.99, DATEADD(day, -18, GETDATE())),
    (3, 8, 79.99, DATEADD(day, -15, GETDATE())),
    (4, 12, 19.99, DATEADD(day, -10, GETDATE())),
    (5, 7, 49.99, DATEADD(day, -8, GETDATE())),
    (6, 3, 59.99, DATEADD(day, -5, GETDATE())),
    (7, 2, 89.99, DATEADD(day, -3, GETDATE())),
    (8, 20, 4.99, DATEADD(day, -2, GETDATE())),
    (9, 15, 7.99, DATEADD(day, -1, GETDATE())),
    -- Add more recent sales for trending data
    (1, 1, 899.99, DATEADD(day, -1, GETDATE())),
    (2, 3, 499.99, DATEADD(day, -1, GETDATE())),
    (3, 5, 79.99, DATEADD(day, -2, GETDATE())),
    (4, 8, 19.99, DATEADD(day, -2, GETDATE()));
GO
