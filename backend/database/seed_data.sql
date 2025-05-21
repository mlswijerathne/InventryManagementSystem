-- Seed data for Computer Accessories Inventory Management System

USE inventory_management;
GO

-- Clear existing data to avoid conflicts
DELETE FROM sale;
DELETE FROM purchase;
DELETE FROM product;
DELETE FROM category;
GO

-- Reset identity columns
DBCC CHECKIDENT ('sale', RESEED, 0);
DBCC CHECKIDENT ('purchase', RESEED, 0);
DBCC CHECKIDENT ('product', RESEED, 0);
DBCC CHECKIDENT ('category', RESEED, 0);
GO

-- Insert computer accessories categories
INSERT INTO category (name, description)
VALUES 
    ('Input Devices', 'Keyboards, mice, and other input peripherals'),
    ('Storage Devices', 'Hard drives, SSDs, and external storage'),
    ('Display Accessories', 'Monitors, adapters, and cables'),
    ('Networking Components', 'Routers, switches, and networking accessories'),
    ('Audio Equipment', 'Headphones, speakers, and microphones'),
    ('PC Components', 'Internal computer parts and components'),
    ('Printing Supplies', 'Printers and printing accessories'),
    ('Laptop Accessories', 'Cooling pads, stands, and laptop peripherals');
GO

-- Insert computer accessories products with base_price and profit_percentage
INSERT INTO product (name, category_id, base_price, price, profit_percentage, quantity, reorder_level)
VALUES
    -- Input Devices (category_id = 1)
    ('Mechanical Gaming Keyboard', 1, 100.00, 129.99, 30.0, 25, 5),
    ('Wireless Optical Mouse', 1, 50.00, 69.99, 40.0, 30, 8),
    ('Ergonomic Keyboard', 1, 65.00, 89.99, 38.5, 15, 5),
    ('Gaming Mouse with RGB', 1, 60.00, 79.99, 33.3, 20, 5),
    ('Keyboard and Mouse Combo', 1, 75.00, 99.99, 33.3, 18, 5),
    
    -- Storage Devices (category_id = 2)
    ('1TB External HDD', 2, 50.00, 69.99, 40.0, 25, 6),
    ('500GB SSD', 2, 65.00, 89.99, 38.5, 20, 5),
    ('1TB M.2 NVMe SSD', 2, 100.00, 129.99, 30.0, 15, 5),
    ('128GB USB Flash Drive', 2, 20.00, 29.99, 50.0, 40, 10),
    ('4TB External Backup Drive', 2, 250.00, 349.99, 40.0, 10, 3),
    
    -- Display Accessories (category_id = 3)
    ('27" 4K Monitor', 3, 230.00, 299.99, 30.4, 12, 3),
    ('Ultrawide Curved Monitor', 3, 300.00, 399.99, 33.3, 8, 2),
    ('HDMI Cable 2.1 (2m)', 3, 15.00, 19.99, 33.3, 50, 15),
    ('DisplayPort to HDMI Adapter', 3, 18.00, 24.99, 38.8, 35, 10),
    ('Monitor Stand', 3, 50.00, 69.99, 40.0, 20, 5),
    
    -- Networking Components (category_id = 4)
    ('Mesh WiFi System (3-pack)', 4, 180.00, 249.99, 38.9, 10, 3),
    ('Gigabit Ethernet Switch (8-port)', 4, 45.00, 59.99, 33.3, 15, 5),
    ('WiFi 6 Router', 4, 130.00, 179.99, 38.5, 12, 4),
    ('Cat 6 Ethernet Cable (5m)', 4, 10.00, 14.99, 49.9, 45, 15),
    ('USB WiFi Adapter', 4, 30.00, 39.99, 33.3, 25, 8);
GO

-- Insert purchase data (last 3 months, from oldest to newest)
INSERT INTO purchase (product_id, quantity, purchase_price, supplier, purchase_date)
VALUES
    -- 3 months ago
    (1, 15, 100.00, 'Tech Distributors Inc.', DATEADD(month, -3, GETDATE())),
    (6, 10, 50.00, 'Storage Solutions Ltd.', DATEADD(month, -3, GETDATE())),
    (11, 5, 230.00, 'Display Technologies', DATEADD(month, -3, GETDATE())),
    (16, 5, 180.00, 'Network Systems Co.', DATEADD(month, -3, GETDATE())),
    
    -- 2 months ago
    (2, 20, 50.00, 'Input Devices Co.', DATEADD(month, -2, GETDATE())),
    (7, 10, 65.00, 'Storage Solutions Ltd.', DATEADD(month, -2, GETDATE())),
    (12, 5, 300.00, 'Display Technologies', DATEADD(month, -2, GETDATE())),
    (17, 8, 45.00, 'Network Systems Co.', DATEADD(month, -2, GETDATE())),
    
    -- 1 month ago
    (3, 10, 65.00, 'Input Devices Co.', DATEADD(month, -1, GETDATE())),
    (8, 8, 100.00, 'Storage Solutions Ltd.', DATEADD(month, -1, GETDATE())),
    (13, 25, 15.00, 'Cable Express', DATEADD(month, -1, GETDATE())),
    (18, 7, 130.00, 'Network Systems Co.', DATEADD(month, -1, GETDATE())),
    
    -- Recent purchases (last 15 days)
    (4, 10, 60.00, 'Tech Distributors Inc.', DATEADD(day, -15, GETDATE())),
    (9, 20, 20.00, 'Storage Solutions Ltd.', DATEADD(day, -10, GETDATE())),
    (14, 15, 18.00, 'Cable Express', DATEADD(day, -7, GETDATE())),
    (19, 25, 10.00, 'Network Systems Co.', DATEADD(day, -3, GETDATE())),
    (5, 10, 75.00, 'Input Devices Co.', DATEADD(day, -1, GETDATE()));
GO

-- Insert sale data (with patterns suitable for data mining and analytics)
INSERT INTO sale (product_id, quantity, sale_price, sale_date)
VALUES
    -- 3 months ago
    (1, 3, 129.99, DATEADD(month, -3, DATEADD(day, -20, GETDATE()))),
    (6, 2, 69.99, DATEADD(month, -3, DATEADD(day, -18, GETDATE()))),
    (11, 1, 299.99, DATEADD(month, -3, DATEADD(day, -15, GETDATE()))),
    (16, 1, 249.99, DATEADD(month, -3, DATEADD(day, -10, GETDATE()))),
    
    -- 2 months ago 
    (2, 4, 69.99, DATEADD(month, -2, DATEADD(day, -25, GETDATE()))),
    (7, 3, 89.99, DATEADD(month, -2, DATEADD(day, -20, GETDATE()))),
    (12, 1, 399.99, DATEADD(month, -2, DATEADD(day, -15, GETDATE()))),
    (17, 2, 59.99, DATEADD(month, -2, DATEADD(day, -10, GETDATE()))),
    (1, 5, 129.99, DATEADD(month, -2, DATEADD(day, -5, GETDATE()))),
    
    -- 1 month ago
    (3, 4, 89.99, DATEADD(month, -1, DATEADD(day, -25, GETDATE()))),
    (8, 2, 129.99, DATEADD(month, -1, DATEADD(day, -20, GETDATE()))),
    (13, 10, 19.99, DATEADD(month, -1, DATEADD(day, -15, GETDATE()))),
    (18, 3, 179.99, DATEADD(month, -1, DATEADD(day, -10, GETDATE()))),
    (2, 5, 69.99, DATEADD(month, -1, DATEADD(day, -5, GETDATE()))),
    
    -- Recent sales (last 30 days)
    (1, 4, 129.99, DATEADD(day, -30, GETDATE())),
    (2, 6, 69.99, DATEADD(day, -25, GETDATE())),
    (3, 3, 89.99, DATEADD(day, -20, GETDATE())),
    (4, 5, 79.99, DATEADD(day, -15, GETDATE())),
    (5, 2, 99.99, DATEADD(day, -10, GETDATE())),
    
    -- Last week
    (1, 5, 129.99, DATEADD(day, -7, GETDATE())),
    (6, 3, 69.99, DATEADD(day, -6, GETDATE())),
    (11, 2, 299.99, DATEADD(day, -5, GETDATE())),
    (16, 1, 249.99, DATEADD(day, -4, GETDATE())),
    (2, 4, 69.99, DATEADD(day, -3, GETDATE())),
    (7, 2, 89.99, DATEADD(day, -2, GETDATE())),
    (12, 1, 399.99, DATEADD(day, -1, GETDATE())),
    
    -- Today's sales
    (1, 3, 129.99, GETDATE()),
    (2, 5, 69.99, GETDATE()),
    (13, 8, 19.99, GETDATE()),
    (4, 4, 79.99, GETDATE()),
    (9, 3, 29.99, GETDATE());
GO