-- Enhanced Seed data for Computer Accessories Inventory Management System
-- Added realistic product categories, pricing, and transaction data

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
    ('Laptop Accessories', 'Cooling pads, stands, and laptop peripherals'),
    ('Mobile Accessories', 'Smartphone and tablet peripherals'),
    ('Gaming Accessories', 'Gaming-specific peripherals and accessories');
GO

-- Insert computer accessories products with base_price and profit_percentage
-- Price calculation formula: price = base_price * (1 + (profit_percentage / 100))
INSERT INTO product (name, category_id, base_price, price, profit_percentage, quantity, reorder_level)
VALUES
    -- Input Devices (category_id = 1)
    ('Mechanical Gaming Keyboard RGB', 1, 85.00, 119.00, 40.0, 25, 5),
    ('Wireless Ergonomic Mouse', 1, 42.85, 59.99, 40.0, 30, 8),
    ('Ergonomic Split Keyboard', 1, 71.43, 99.99, 40.0, 15, 5),
    ('Gaming Mouse with 16K DPI', 1, 49.99, 69.99, 40.0, 20, 5),
    ('Keyboard and Mouse Combo', 1, 60.00, 78.00, 30.0, 18, 5),
    ('Premium Mechanical Keyboard Brown Switches', 1, 120.00, 179.99, 50.0, 12, 4),
    ('Vertical Ergonomic Mouse', 1, 35.71, 49.99, 40.0, 22, 6),
    
    -- Storage Devices (category_id = 2)
    ('2TB External HDD', 2, 70.00, 89.99, 28.6, 25, 6),
    ('1TB SSD SATA', 2, 81.25, 109.99, 35.4, 20, 5),
    ('2TB M.2 NVMe SSD', 2, 150.00, 199.99, 33.3, 15, 5),
    ('256GB USB Flash Drive', 2, 38.46, 49.99, 30.0, 40, 10),
    ('8TB External Backup Drive', 2, 230.77, 299.99, 30.0, 10, 3),
    ('500GB Portable SSD', 2, 76.92, 99.99, 30.0, 18, 5),
    ('4TB Internal HDD', 2, 76.92, 99.99, 30.0, 15, 4),
    
    -- Display Accessories (category_id = 3)
    ('27" 4K IPS Monitor', 3, 230.00, 299.99, 30.4, 12, 3),
    ('34" Ultrawide Curved Monitor', 3, 300.00, 419.99, 40.0, 8, 2),
    ('HDMI Cable 2.1 (3m)', 3, 15.38, 19.99, 30.0, 50, 15),
    ('DisplayPort to HDMI Adapter', 3, 18.46, 23.99, 30.0, 35, 10),
    ('Dual Monitor Stand', 3, 53.85, 69.99, 30.0, 20, 5),
    ('32" 4K HDR Monitor', 3, 307.69, 399.99, 30.0, 10, 3),
    ('Monitor Privacy Filter', 3, 30.77, 39.99, 30.0, 15, 5),
    
    -- Networking Components (category_id = 4)
    ('Mesh WiFi System (3-pack)', 4, 169.23, 219.99, 30.0, 10, 3),
    ('Gigabit Ethernet Switch (16-port)', 4, 53.85, 69.99, 30.0, 15, 5),
    ('WiFi 6E Router', 4, 169.23, 219.99, 30.0, 12, 4),
    ('Cat 8 Ethernet Cable (10m)', 4, 19.23, 24.99, 30.0, 45, 15),
    ('USB WiFi 6 Adapter', 4, 34.62, 44.99, 30.0, 25, 8),
    ('Network Cable Tester', 4, 23.08, 29.99, 30.0, 12, 4),
    ('PoE Network Switch', 4, 76.92, 99.99, 30.0, 8, 3),
    
    -- Audio Equipment (category_id = 5)
    ('Wireless Noise-Cancelling Headphones', 5, 153.85, 199.99, 30.0, 20, 5),
    ('2.1 Computer Speakers', 5, 76.92, 99.99, 30.0, 15, 5),
    ('USB Condenser Microphone', 5, 92.31, 119.99, 30.0, 12, 4),
    ('Gaming Headset with Surround Sound', 5, 76.92, 99.99, 30.0, 25, 6),
    ('Bluetooth Earbuds', 5, 61.54, 79.99, 30.0, 30, 8),
    ('Sound Card External', 5, 76.92, 99.99, 30.0, 10, 3),
    ('Audio Interface USB', 5, 115.38, 149.99, 30.0, 8, 3),
    
    -- PC Components (category_id = 6)
    ('16GB DDR4 RAM Kit (2x8GB)', 6, 61.54, 79.99, 30.0, 25, 6),
    ('650W Power Supply 80+ Gold', 6, 76.92, 99.99, 30.0, 15, 4),
    ('Mid-Tower PC Case', 6, 69.23, 89.99, 30.0, 10, 3),
    ('CPU Cooler Liquid AIO', 6, 92.31, 119.99, 30.0, 12, 4),
    ('AMD Ryzen 7 Processor', 6, 269.23, 349.99, 30.0, 8, 2),
    ('Intel Core i7 Processor', 6, 307.69, 399.99, 30.0, 8, 2),
    ('RTX 3060 Graphics Card', 6, 307.69, 399.99, 30.0, 5, 2),
    
    -- Printing Supplies (category_id = 7)
    ('Laser Printer Toner Cartridge', 7, 50.00, 65.00, 30.0, 20, 5),
    ('Inkjet Printer Cartridge Set', 7, 46.15, 59.99, 30.0, 25, 6),
    ('Photo Paper Premium (100 sheets)', 7, 15.38, 19.99, 30.0, 30, 8),
    ('Label Printer', 7, 92.31, 119.99, 30.0, 10, 3),
    ('Thermal Receipt Paper Rolls (10 pack)', 7, 15.38, 19.99, 30.0, 40, 10),
    ('Color Laser Printer', 7, 230.77, 299.99, 30.0, 5, 2),
    ('3D Printer Filament PLA', 7, 23.08, 29.99, 30.0, 20, 5),
    
    -- Laptop Accessories (category_id = 8)
    ('Laptop Cooling Pad', 8, 30.77, 39.99, 30.0, 20, 6),
    ('Laptop Stand Adjustable', 8, 38.46, 49.99, 30.0, 15, 5),
    ('Laptop Docking Station', 8, 92.31, 119.99, 30.0, 12, 4),
    ('Laptop Privacy Screen', 8, 23.08, 29.99, 30.0, 25, 7),
    ('Laptop Sleeve 15.6"', 8, 19.23, 24.99, 30.0, 30, 8),
    ('Universal Laptop Charger', 8, 38.46, 49.99, 30.0, 20, 5),
    ('Laptop External Battery', 8, 76.92, 99.99, 30.0, 15, 4),
    
    -- Mobile Accessories (category_id = 9)
    ('Fast Wireless Charger', 9, 23.08, 29.99, 30.0, 30, 8),
    ('Phone Case Premium', 9, 23.08, 29.99, 30.0, 40, 10),
    ('Tempered Glass Screen Protector', 9, 11.54, 14.99, 30.0, 50, 15),
    ('Phone Camera Lens Kit', 9, 30.77, 39.99, 30.0, 20, 5),
    ('Bluetooth Selfie Stick', 9, 15.38, 19.99, 30.0, 25, 7),
    ('Phone Grip Stand', 9, 9.23, 11.99, 30.0, 45, 12),
    ('USB-C to Lightning Cable', 9, 19.23, 24.99, 30.0, 35, 10),
    
    -- Gaming Accessories (category_id = 10)
    ('Gaming Controller Wireless', 10, 46.15, 59.99, 30.0, 25, 6),
    ('RGB Gaming Mouse Pad XL', 10, 23.08, 29.99, 30.0, 30, 8),
    ('Gaming Chair Ergonomic', 10, 153.85, 199.99, 30.0, 10, 3),
    ('Gaming Desk', 10, 153.85, 199.99, 30.0, 8, 2),
    ('Streaming Deck', 10, 115.38, 149.99, 30.0, 12, 4),
    ('VR Headset', 10, 307.69, 399.99, 30.0, 5, 2),
    ('Gaming Console', 10, 384.62, 499.99, 30.0, 8, 3);
GO

-- Insert purchase data (historical and recent, from oldest to newest)
-- Showing different suppliers, volumes, and pricing patterns
INSERT INTO purchase (product_id, quantity, purchase_price, supplier, purchase_date)
VALUES
    -- 5 months ago
    (1, 15, 85.00, 'TechWorld Distributors', DATEADD(month, -5, GETDATE())),
    (8, 20, 70.00, 'Storage Solutions Inc.', DATEADD(month, -5, DATEADD(day, -5, GETDATE()))),
    (15, 10, 230.00, 'DisplayTech Ltd', DATEADD(month, -5, DATEADD(day, -10, GETDATE()))),
    (22, 12, 169.23, 'NetworkPro Supplies', DATEADD(month, -5, DATEADD(day, -15, GETDATE()))),
    (29, 15, 153.85, 'AudioPhile Distributors', DATEADD(month, -5, DATEADD(day, -20, GETDATE()))),

    -- 4 months ago
    (2, 20, 42.85, 'TechWorld Distributors', DATEADD(month, -4, GETDATE())),
    (9, 15, 81.25, 'Storage Solutions Inc.', DATEADD(month, -4, DATEADD(day, -5, GETDATE()))),
    (16, 8, 300.00, 'DisplayTech Ltd', DATEADD(month, -4, DATEADD(day, -10, GETDATE()))),
    (36, 15, 61.54, 'ComponentMaster Pro', DATEADD(month, -4, DATEADD(day, -15, GETDATE()))),
    (43, 15, 50.00, 'PrintSupply Co', DATEADD(month, -4, DATEADD(day, -20, GETDATE()))),
    
    -- 3 months ago
    (3, 20, 71.43, 'TechWorld Distributors', DATEADD(month, -3, GETDATE())),
    (10, 15, 150.00, 'Storage Solutions Inc.', DATEADD(month, -3, DATEADD(day, -5, GETDATE()))),
    (17, 30, 15.38, 'CableTech Solutions', DATEADD(month, -3, DATEADD(day, -10, GETDATE()))),
    (23, 15, 53.85, 'NetworkPro Supplies', DATEADD(month, -3, DATEADD(day, -15, GETDATE()))),
    (30, 15, 76.92, 'AudioPhile Distributors', DATEADD(month, -3, DATEADD(day, -20, GETDATE()))),
    (37, 15, 76.92, 'ComponentMaster Pro', DATEADD(month, -3, DATEADD(day, -22, GETDATE()))),
    (50, 20, 30.77, 'LaptopGear Inc.', DATEADD(month, -3, DATEADD(day, -25, GETDATE()))),
    (57, 25, 23.08, 'MobileAccessories Ltd', DATEADD(month, -3, DATEADD(day, -28, GETDATE()))),
    
    -- 2 months ago
    (4, 20, 49.99, 'TechWorld Distributors', DATEADD(month, -2, GETDATE())),
    (11, 25, 38.46, 'Storage Solutions Inc.', DATEADD(month, -2, DATEADD(day, -5, GETDATE()))),
    (18, 25, 18.46, 'CableTech Solutions', DATEADD(month, -2, DATEADD(day, -8, GETDATE()))),
    (24, 15, 169.23, 'NetworkPro Supplies', DATEADD(month, -2, DATEADD(day, -12, GETDATE()))),
    (31, 15, 92.31, 'AudioPhile Distributors', DATEADD(month, -2, DATEADD(day, -15, GETDATE()))),
    (38, 10, 69.23, 'ComponentMaster Pro', DATEADD(month, -2, DATEADD(day, -18, GETDATE()))),
    (44, 20, 46.15, 'PrintSupply Co', DATEADD(month, -2, DATEADD(day, -22, GETDATE()))),
    (51, 15, 38.46, 'LaptopGear Inc.', DATEADD(month, -2, DATEADD(day, -25, GETDATE()))),
    (58, 35, 11.54, 'MobileAccessories Ltd', DATEADD(month, -2, DATEADD(day, -28, GETDATE()))),
    (64, 20, 46.15, 'GamersParadise Supply', DATEADD(month, -2, DATEADD(day, -29, GETDATE()))),
    
    -- 1 month ago
    (5, 20, 60.00, 'TechWorld Distributors', DATEADD(month, -1, DATEADD(day, -2, GETDATE()))),
    (12, 10, 230.77, 'Storage Solutions Inc.', DATEADD(month, -1, DATEADD(day, -5, GETDATE()))),
    (19, 15, 53.85, 'DisplayTech Ltd', DATEADD(month, -1, DATEADD(day, -8, GETDATE()))),
    (25, 20, 19.23, 'CableTech Solutions', DATEADD(month, -1, DATEADD(day, -10, GETDATE()))),
    (32, 20, 76.92, 'AudioPhile Distributors', DATEADD(month, -1, DATEADD(day, -12, GETDATE()))),
    (39, 10, 92.31, 'ComponentMaster Pro', DATEADD(month, -1, DATEADD(day, -15, GETDATE()))),
    (45, 20, 15.38, 'PrintSupply Co', DATEADD(month, -1, DATEADD(day, -18, GETDATE()))),
    (52, 15, 23.08, 'LaptopGear Inc.', DATEADD(month, -1, DATEADD(day, -22, GETDATE()))),
    (59, 20, 30.77, 'MobileAccessories Ltd', DATEADD(month, -1, DATEADD(day, -25, GETDATE()))),
    (65, 25, 23.08, 'GamersParadise Supply', DATEADD(month, -1, DATEADD(day, -28, GETDATE()))),
    (6, 12, 120.00, 'TechWorld Distributors', DATEADD(month, -1, DATEADD(day, -29, GETDATE()))),
    
    -- Recent purchases (last 30 days)
    (7, 22, 35.71, 'TechWorld Distributors', DATEADD(day, -30, GETDATE())),
    (13, 18, 76.92, 'Storage Solutions Inc.', DATEADD(day, -28, GETDATE())),
    (20, 10, 307.69, 'DisplayTech Ltd', DATEADD(day, -25, GETDATE())),
    (26, 10, 34.62, 'NetworkPro Supplies', DATEADD(day, -22, GETDATE())),
    (33, 20, 61.54, 'AudioPhile Distributors', DATEADD(day, -20, GETDATE())),
    (40, 10, 269.23, 'ComponentMaster Pro', DATEADD(day, -18, GETDATE())),
    (46, 5, 230.77, 'PrintSupply Co', DATEADD(day, -15, GETDATE())),
    (53, 15, 19.23, 'LaptopGear Inc.', DATEADD(day, -12, GETDATE())),
    (60, 35, 9.23, 'MobileAccessories Ltd', DATEADD(day, -10, GETDATE())),
    (66, 8, 153.85, 'GamersParadise Supply', DATEADD(day, -8, GETDATE())),
    (14, 15, 76.92, 'Storage Solutions Inc.', DATEADD(day, -5, GETDATE())),
    (21, 12, 23.08, 'NetworkPro Supplies', DATEADD(day, -3, GETDATE())),
    (27, 8, 76.92, 'NetworkPro Supplies', DATEADD(day, -1, GETDATE())),
    (41, 8, 307.69, 'ComponentMaster Pro', GETDATE()),
    (47, 20, 23.08, 'PrintSupply Co', GETDATE());
GO

-- Insert sale data (historical and recent, showing sales patterns over time)
INSERT INTO sale (product_id, quantity, sale_price, sale_date)
VALUES
    -- 5 months ago
    (1, 5, 119.00, DATEADD(month, -5, DATEADD(day, -5, GETDATE()))),
    (8, 8, 89.99, DATEADD(month, -5, DATEADD(day, -8, GETDATE()))),
    (15, 3, 299.99, DATEADD(month, -5, DATEADD(day, -12, GETDATE()))),
    (22, 4, 219.99, DATEADD(month, -5, DATEADD(day, -15, GETDATE()))),
    (29, 6, 199.99, DATEADD(month, -5, DATEADD(day, -20, GETDATE()))),
    
    -- 4 months ago
    (1, 4, 119.00, DATEADD(month, -4, DATEADD(day, -3, GETDATE()))),
    (2, 7, 59.99, DATEADD(month, -4, DATEADD(day, -6, GETDATE()))),
    (8, 5, 89.99, DATEADD(month, -4, DATEADD(day, -9, GETDATE()))),
    (9, 6, 109.99, DATEADD(month, -4, DATEADD(day, -12, GETDATE()))),
    (15, 2, 299.99, DATEADD(month, -4, DATEADD(day, -15, GETDATE()))),
    (16, 3, 419.99, DATEADD(month, -4, DATEADD(day, -18, GETDATE()))),
    (36, 10, 79.99, DATEADD(month, -4, DATEADD(day, -21, GETDATE()))),
    (43, 8, 65.00, DATEADD(month, -4, DATEADD(day, -24, GETDATE()))),
    
    -- 3 months ago
    (3, 6, 99.99, DATEADD(month, -3, DATEADD(day, -2, GETDATE()))),
    (10, 4, 199.99, DATEADD(month, -3, DATEADD(day, -5, GETDATE()))),
    (17, 15, 19.99, DATEADD(month, -3, DATEADD(day, -8, GETDATE()))),
    (23, 6, 69.99, DATEADD(month, -3, DATEADD(day, -11, GETDATE()))),
    (30, 5, 99.99, DATEADD(month, -3, DATEADD(day, -14, GETDATE()))),
    (37, 7, 99.99, DATEADD(month, -3, DATEADD(day, -17, GETDATE()))),
    (50, 9, 39.99, DATEADD(month, -3, DATEADD(day, -20, GETDATE()))),
    (57, 15, 29.99, DATEADD(month, -3, DATEADD(day, -23, GETDATE()))),
    (1, 6, 119.00, DATEADD(month, -3, DATEADD(day, -26, GETDATE()))),
    (8, 4, 89.99, DATEADD(month, -3, DATEADD(day, -29, GETDATE()))),
    
    -- 2 months ago
    (4, 8, 69.99, DATEADD(month, -2, DATEADD(day, -2, GETDATE()))),
    (11, 12, 49.99, DATEADD(month, -2, DATEADD(day, -4, GETDATE()))),
    (18, 10, 23.99, DATEADD(month, -2, DATEADD(day, -6, GETDATE()))),
    (24, 5, 219.99, DATEADD(month, -2, DATEADD(day, -8, GETDATE()))),
    (31, 4, 119.99, DATEADD(month, -2, DATEADD(day, -10, GETDATE()))),
    (38, 5, 89.99, DATEADD(month, -2, DATEADD(day, -12, GETDATE()))),
    (44, 10, 59.99, DATEADD(month, -2, DATEADD(day, -14, GETDATE()))),
    (51, 8, 49.99, DATEADD(month, -2, DATEADD(day, -16, GETDATE()))),
    (58, 20, 14.99, DATEADD(month, -2, DATEADD(day, -18, GETDATE()))),
    (64, 12, 59.99, DATEADD(month, -2, DATEADD(day, -20, GETDATE()))),
    (2, 8, 59.99, DATEADD(month, -2, DATEADD(day, -22, GETDATE()))),
    (9, 5, 109.99, DATEADD(month, -2, DATEADD(day, -24, GETDATE()))),
    (16, 2, 419.99, DATEADD(month, -2, DATEADD(day, -26, GETDATE()))),
    (23, 7, 69.99, DATEADD(month, -2, DATEADD(day, -28, GETDATE()))),
    
    -- 1 month ago
    (5, 7, 78.00, DATEADD(month, -1, DATEADD(day, -2, GETDATE()))),
    (12, 4, 299.99, DATEADD(month, -1, DATEADD(day, -4, GETDATE()))),
    (19, 8, 69.99, DATEADD(month, -1, DATEADD(day, -6, GETDATE()))),
    (25, 15, 24.99, DATEADD(month, -1, DATEADD(day, -8, GETDATE()))),
    (32, 8, 99.99, DATEADD(month, -1, DATEADD(day, -10, GETDATE()))),
    (39, 5, 119.99, DATEADD(month, -1, DATEADD(day, -12, GETDATE()))),
    (45, 15, 19.99, DATEADD(month, -1, DATEADD(day, -14, GETDATE()))),
    (52, 10, 29.99, DATEADD(month, -1, DATEADD(day, -16, GETDATE()))),
    (59, 8, 39.99, DATEADD(month, -1, DATEADD(day, -18, GETDATE()))),
    (65, 15, 29.99, DATEADD(month, -1, DATEADD(day, -20, GETDATE()))),
    (6, 5, 179.99, DATEADD(month, -1, DATEADD(day, -22, GETDATE()))),
    (3, 4, 99.99, DATEADD(month, -1, DATEADD(day, -24, GETDATE()))),
    (10, 3, 199.99, DATEADD(month, -1, DATEADD(day, -26, GETDATE()))),
    (17, 12, 19.99, DATEADD(month, -1, DATEADD(day, -28, GETDATE()))),
    
    -- Recent sales (last 30 days)
    (7, 10, 49.99, DATEADD(day, -30, GETDATE())),
    (13, 6, 99.99, DATEADD(day, -28, GETDATE())),
    (20, 4, 399.99, DATEADD(day, -26, GETDATE())),
    (26, 7, 44.99, DATEADD(day, -24, GETDATE())),
    (33, 12, 79.99, DATEADD(day, -22, GETDATE())),
    (40, 3, 349.99, DATEADD(day, -20, GETDATE())),
    (46, 2, 299.99, DATEADD(day, -18, GETDATE())),
    (53, 12, 24.99, DATEADD(day, -16, GETDATE())),
    (60, 20, 11.99, DATEADD(day, -14, GETDATE())),
    (66, 4, 199.99, DATEADD(day, -12, GETDATE())),
    
    -- Last two weeks
    (1, 5, 119.00, DATEADD(day, -14, GETDATE())),
    (8, 3, 89.99, DATEADD(day, -13, GETDATE())),
    (15, 2, 299.99, DATEADD(day, -12, GETDATE())),
    (22, 1, 219.99, DATEADD(day, -11, GETDATE())),
    (29, 3, 199.99, DATEADD(day, -10, GETDATE())),
    (36, 5, 79.99, DATEADD(day, -9, GETDATE())),
    (43, 4, 65.00, DATEADD(day, -8, GETDATE())),
    (2, 6, 59.99, DATEADD(day, -7, GETDATE())),
    (9, 4, 109.99, DATEADD(day, -6, GETDATE())),
    (16, 1, 419.99, DATEADD(day, -5, GETDATE())),
    
    -- Last few days
    (3, 3, 99.99, DATEADD(day, -4, GETDATE())),
    (10, 2, 199.99, DATEADD(day, -3, GETDATE())),
    (17, 8, 19.99, DATEADD(day, -2, GETDATE())),
    (24, 1, 219.99, DATEADD(day, -1, GETDATE())),
    
    -- Today's sales
    (4, 4, 69.99, GETDATE()),
    (11, 5, 49.99, GETDATE()),
    (18, 6, 23.99, GETDATE()),
    (25, 3, 24.99, GETDATE()),
    (32, 2, 99.99, GETDATE()),
    (39, 1, 119.99, GETDATE()),
    (46, 1, 299.99, GETDATE());
GO
