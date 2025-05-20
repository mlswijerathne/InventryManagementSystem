-- Seed data for the Computer Accessories Inventory Management System

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
    ('Storage Devices', 'Hard drives, SSDs, USB drives, memory cards'),
    ('Display Accessories', 'Monitors, projectors, adapters, cables'),
    ('Networking Components', 'Routers, switches, network cards, cables'),
    ('Audio Equipment', 'Speakers, headphones, microphones, sound cards'),
    ('PC Components', 'Motherboards, CPUs, RAM, power supplies, PC cases'),
    ('Printing Supplies', 'Printers, scanners, ink, toner, paper'),
    ('Laptop Accessories', 'Laptop bags, cooling pads, docking stations');
GO

-- Insert computer accessories products
INSERT INTO product (name, category_id, price, quantity, reorder_level)
VALUES
    -- Input Devices (category_id = 1)
    ('Mechanical Gaming Keyboard', 1, 129.99, 45, 10),
    ('Wireless Ergonomic Mouse', 1, 69.99, 60, 15),
    ('Bluetooth Trackpad', 1, 89.99, 30, 8),
    ('Graphics Tablet', 1, 199.99, 20, 5),
    ('USB Numeric Keypad', 1, 24.99, 40, 10),
    ('Gaming Mouse Pad (XL)', 1, 19.99, 75, 20),
    ('Wireless Presenter Remote', 1, 39.99, 25, 8),
    ('Fingerprint Scanner', 1, 79.99, 15, 5),
    
    -- Storage Devices (category_id = 2)
    ('1TB External HDD', 2, 69.99, 50, 12),
    ('500GB SSD', 2, 89.99, 40, 10),
    ('1TB M.2 NVMe SSD', 2, 129.99, 35, 8),
    ('128GB USB Flash Drive', 2, 29.99, 60, 15),
    ('512GB MicroSD Card', 2, 49.99, 45, 10),
    ('4TB Network Attached Storage', 2, 349.99, 20, 5),
    ('8TB External Backup Drive', 2, 179.99, 25, 6),
    ('Portable SSD 1TB', 2, 159.99, 30, 8),
    
    -- Display Accessories (category_id = 3)
    ('27" 4K Monitor', 3, 299.99, 25, 5),
    ('Ultrawide Curved Monitor', 3, 399.99, 20, 5),
    ('Dual Monitor Stand', 3, 79.99, 30, 8),
    ('HDMI Cable 2.1 (2m)', 3, 19.99, 50, 15),
    ('DisplayPort to HDMI Adapter', 3, 24.99, 40, 10),
    ('USB-C to DisplayPort Cable', 3, 29.99, 35, 10),
    ('Mini Projector', 3, 249.99, 15, 5),
    ('Monitor Privacy Filter', 3, 49.99, 25, 8),
    
    -- Networking Components (category_id = 4)
    ('Mesh WiFi System (3-pack)', 4, 249.99, 20, 5),
    ('Gigabit Ethernet Switch (8-port)', 4, 59.99, 30, 8),
    ('WiFi 6 Router', 4, 179.99, 25, 6),
    ('Network Cable Tester', 4, 29.99, 15, 5),
    ('Cat 6 Ethernet Cable (5m)', 4, 14.99, 60, 15),
    ('USB WiFi Adapter', 4, 39.99, 40, 10),
    ('Bluetooth 5.0 Adapter', 4, 19.99, 35, 10),
    ('Network Card PCIe', 4, 49.99, 25, 8),
    
    -- Audio Equipment (category_id = 5)
    ('Gaming Headset', 5, 99.99, 40, 10),
    ('Wireless Earbuds', 5, 129.99, 50, 12),
    ('USB Condenser Microphone', 5, 89.99, 30, 8),
    ('Computer Speakers (2.1)', 5, 79.99, 35, 10),
    ('Sound Bar for PC', 5, 119.99, 25, 6),
    ('External USB Sound Card', 5, 49.99, 20, 5),
    ('Noise Cancelling Headphones', 5, 199.99, 30, 8),
    ('Podcast Microphone Kit', 5, 149.99, 15, 5),
    
    -- PC Components (category_id = 6)
    ('Gaming Graphics Card', 6, 499.99, 25, 5),
    ('CPU Cooler', 6, 69.99, 30, 8),
    ('16GB RAM Kit (2x8GB)', 6, 89.99, 40, 10),
    ('750W Power Supply', 6, 99.99, 35, 8),
    ('Mid-Tower PC Case', 6, 79.99, 25, 6),
    ('Thermal Paste', 6, 9.99, 50, 15),
    ('Case Fans (3-pack)', 6, 39.99, 30, 10),
    ('Internal Card Reader', 6, 29.99, 20, 8),
    
    -- Printing Supplies (category_id = 7)
    ('Color Laser Printer', 7, 349.99, 20, 5),
    ('All-in-One Inkjet Printer', 7, 199.99, 25, 6),
    ('Black Toner Cartridge', 7, 79.99, 45, 15),
    ('Color Ink Cartridges (Set)', 7, 59.99, 50, 15),
    ('Photo Paper Premium', 7, 19.99, 60, 20),
    ('Document Scanner', 7, 179.99, 15, 5),
    ('Label Printer', 7, 129.99, 20, 5),
    ('Printer Cable USB', 7, 14.99, 40, 12),
    
    -- Laptop Accessories (category_id = 8)
    ('Laptop Cooling Pad', 8, 39.99, 40, 10),
    ('Universal Laptop Charger', 8, 59.99, 35, 10),
    ('Laptop Docking Station', 8, 149.99, 25, 6),
    ('Laptop Backpack', 8, 69.99, 50, 12),
    ('Privacy Screen Filter', 8, 34.99, 30, 8),
    ('Laptop Stand', 8, 29.99, 45, 12),
    ('Laptop Sleeve 15"', 8, 24.99, 55, 15),
    ('Laptop Battery Replacement', 8, 89.99, 20, 8);
GO

-- Insert purchase data (last 6 months of data, starting from oldest to newest)
INSERT INTO purchase (product_id, quantity, purchase_price, supplier, purchase_date)
VALUES
    -- 6 months ago purchases
    (1, 15, 110.00, 'Tech Distributors Inc.', DATEADD(month, -6, GETDATE())),
    (10, 20, 60.00, 'Storage Solutions Ltd.', DATEADD(month, -6, GETDATE())),
    (18, 10, 280.00, 'Display Technologies', DATEADD(month, -6, GETDATE())),
    (25, 8, 220.00, 'Network Systems Co.', DATEADD(month, -6, GETDATE())),
    (34, 12, 70.00, 'Audio World', DATEADD(month, -6, GETDATE())),
    (41, 10, 450.00, 'PC Parts Wholesale', DATEADD(month, -6, GETDATE())),
    (49, 8, 320.00, 'Printer Supplies Inc.', DATEADD(month, -6, GETDATE())),
    (57, 15, 35.00, 'Laptop Gear Ltd.', DATEADD(month, -6, GETDATE())),
    
    -- 5 months ago purchases
    (2, 20, 60.00, 'Input Devices Co.', DATEADD(month, -5, GETDATE())),
    (11, 15, 80.00, 'Storage Solutions Ltd.', DATEADD(month, -5, GETDATE())),
    (19, 8, 370.00, 'Display Technologies', DATEADD(month, -5, GETDATE())),
    (26, 12, 50.00, 'Network Systems Co.', DATEADD(month, -5, GETDATE())),
    (33, 15, 80.00, 'Audio World', DATEADD(month, -5, GETDATE())),
    (42, 12, 60.00, 'PC Parts Wholesale', DATEADD(month, -5, GETDATE())),
    (50, 10, 180.00, 'Printer Supplies Inc.', DATEADD(month, -5, GETDATE())),
    (58, 12, 50.00, 'Laptop Gear Ltd.', DATEADD(month, -5, GETDATE())),
    
    -- 4 months ago purchases
    (3, 10, 80.00, 'Input Devices Co.', DATEADD(month, -4, GETDATE())),
    (12, 20, 25.00, 'Storage Solutions Ltd.', DATEADD(month, -4, GETDATE())),
    (20, 12, 70.00, 'Display Technologies', DATEADD(month, -4, GETDATE())),
    (27, 10, 160.00, 'Network Systems Co.', DATEADD(month, -4, GETDATE())),
    (35, 18, 85.00, 'Audio World', DATEADD(month, -4, GETDATE())),
    (43, 15, 85.00, 'PC Parts Wholesale', DATEADD(month, -4, GETDATE())),
    (51, 20, 70.00, 'Printer Supplies Inc.', DATEADD(month, -4, GETDATE())),
    (59, 10, 130.00, 'Laptop Gear Ltd.', DATEADD(month, -4, GETDATE())),
    
    -- 3 months ago purchases
    (4, 8, 180.00, 'Tech Distributors Inc.', DATEADD(month, -3, GETDATE())),
    (13, 15, 45.00, 'Storage Depot', DATEADD(month, -3, GETDATE())),
    (21, 15, 20.00, 'Cable Express', DATEADD(month, -3, GETDATE())),
    (28, 5, 25.00, 'Network Tools Co.', DATEADD(month, -3, GETDATE())),
    (36, 12, 110.00, 'Sound Solutions', DATEADD(month, -3, GETDATE())),
    (44, 10, 90.00, 'Component World', DATEADD(month, -3, GETDATE())),
    (52, 20, 55.00, 'Ink & Toner Supplies', DATEADD(month, -3, GETDATE())),
    (60, 15, 25.00, 'Mobile Accessories Ltd.', DATEADD(month, -3, GETDATE())),
    
    -- 2 months ago purchases
    (5, 15, 20.00, 'Input Peripherals Inc.', DATEADD(month, -2, GETDATE())),
    (14, 8, 320.00, 'Storage Depot', DATEADD(month, -2, GETDATE())),
    (22, 15, 20.00, 'Cable Express', DATEADD(month, -2, GETDATE())),
    (29, 20, 12.00, 'Network Tools Co.', DATEADD(month, -2, GETDATE())),
    (37, 12, 180.00, 'Sound Solutions', DATEADD(month, -2, GETDATE())),
    (45, 10, 8.00, 'Component World', DATEADD(month, -2, GETDATE())),
    (53, 25, 15.00, 'Ink & Toner Supplies', DATEADD(month, -2, GETDATE())),
    (61, 20, 30.00, 'Mobile Accessories Ltd.', DATEADD(month, -2, GETDATE())),
    
    -- 1 month ago purchases
    (6, 25, 15.00, 'Input Peripherals Inc.', DATEADD(month, -1, GETDATE())),
    (15, 10, 140.00, 'Storage Depot', DATEADD(month, -1, GETDATE())),
    (23, 12, 25.00, 'Cable Express', DATEADD(month, -1, GETDATE())),
    (30, 15, 35.00, 'Network Systems Co.', DATEADD(month, -1, GETDATE())),
    (38, 8, 45.00, 'Sound Solutions', DATEADD(month, -1, GETDATE())),
    (46, 10, 35.00, 'Component World', DATEADD(month, -1, GETDATE())),
    (54, 6, 170.00, 'Printer Systems Inc.', DATEADD(month, -1, GETDATE())),
    (62, 18, 20.00, 'Mobile Accessories Ltd.', DATEADD(month, -1, GETDATE())),
    
    -- Recent purchases (last 15 days)
    (7, 10, 35.00, 'Tech Distributors Inc.', DATEADD(day, -15, GETDATE())),
    (16, 8, 25.00, 'Storage Solutions Ltd.', DATEADD(day, -14, GETDATE())),
    (24, 12, 220.00, 'Display Technologies', DATEADD(day, -13, GETDATE())),
    (31, 15, 13.00, 'Network Systems Co.', DATEADD(day, -12, GETDATE())),
    (39, 10, 130.00, 'Audio World', DATEADD(day, -10, GETDATE())),
    (47, 12, 120.00, 'PC Parts Wholesale', DATEADD(day, -8, GETDATE())),
    (55, 20, 10.00, 'Printer Supplies Inc.', DATEADD(day, -6, GETDATE())),
    (63, 15, 80.00, 'Laptop Gear Ltd.', DATEADD(day, -4, GETDATE()));
GO

-- Insert sales data (with patterns suitable for data mining and analytics)
INSERT INTO sale (product_id, quantity, sale_price, sale_date)
VALUES
    -- 6 months of historical sales data
    -- Month 6 ago
    (1, 3, 129.99, DATEADD(month, -6, DATEADD(day, -25, GETDATE()))),
    (10, 5, 69.99, DATEADD(month, -6, DATEADD(day, -24, GETDATE()))),
    (18, 2, 299.99, DATEADD(month, -6, DATEADD(day, -23, GETDATE()))),
    (25, 1, 249.99, DATEADD(month, -6, DATEADD(day, -22, GETDATE()))),
    (34, 4, 99.99, DATEADD(month, -6, DATEADD(day, -20, GETDATE()))),
    (41, 2, 499.99, DATEADD(month, -6, DATEADD(day, -18, GETDATE()))),
    (49, 1, 349.99, DATEADD(month, -6, DATEADD(day, -15, GETDATE()))),
    (57, 3, 39.99, DATEADD(month, -6, DATEADD(day, -12, GETDATE()))),

    -- Month 5 ago
    (2, 5, 69.99, DATEADD(month, -5, DATEADD(day, -28, GETDATE()))),
    (11, 4, 89.99, DATEADD(month, -5, DATEADD(day, -25, GETDATE()))),
    (19, 1, 399.99, DATEADD(month, -5, DATEADD(day, -23, GETDATE()))),
    (26, 3, 59.99, DATEADD(month, -5, DATEADD(day, -21, GETDATE()))),
    (33, 5, 89.99, DATEADD(month, -5, DATEADD(day, -18, GETDATE()))),
    (42, 4, 69.99, DATEADD(month, -5, DATEADD(day, -15, GETDATE()))),
    (50, 2, 199.99, DATEADD(month, -5, DATEADD(day, -12, GETDATE()))),
    (58, 4, 59.99, DATEADD(month, -5, DATEADD(day, -8, GETDATE()))),
    (1, 2, 129.99, DATEADD(month, -5, DATEADD(day, -5, GETDATE()))),
    (10, 3, 69.99, DATEADD(month, -5, DATEADD(day, -2, GETDATE()))),

    -- Month 4 ago
    (3, 3, 89.99, DATEADD(month, -4, DATEADD(day, -27, GETDATE()))),
    (12, 6, 29.99, DATEADD(month, -4, DATEADD(day, -25, GETDATE()))),
    (20, 5, 79.99, DATEADD(month, -4, DATEADD(day, -22, GETDATE()))),
    (27, 2, 179.99, DATEADD(month, -4, DATEADD(day, -20, GETDATE()))),
    (35, 6, 99.99, DATEADD(month, -4, DATEADD(day, -18, GETDATE()))),
    (43, 5, 99.99, DATEADD(month, -4, DATEADD(day, -15, GETDATE()))),
    (51, 7, 79.99, DATEADD(month, -4, DATEADD(day, -12, GETDATE()))),
    (59, 3, 149.99, DATEADD(month, -4, DATEADD(day, -10, GETDATE()))),
    (2, 4, 69.99, DATEADD(month, -4, DATEADD(day, -8, GETDATE()))),
    (11, 3, 89.99, DATEADD(month, -4, DATEADD(day, -5, GETDATE()))),
    (18, 1, 299.99, DATEADD(month, -4, DATEADD(day, -2, GETDATE()))),

    -- Month 3 ago
    (4, 2, 199.99, DATEADD(month, -3, DATEADD(day, -28, GETDATE()))),
    (13, 5, 49.99, DATEADD(month, -3, DATEADD(day, -25, GETDATE()))),
    (21, 8, 24.99, DATEADD(month, -3, DATEADD(day, -23, GETDATE()))),
    (28, 3, 29.99, DATEADD(month, -3, DATEADD(day, -20, GETDATE()))),
    (36, 4, 119.99, DATEADD(month, -3, DATEADD(day, -18, GETDATE()))),
    (44, 3, 99.99, DATEADD(month, -3, DATEADD(day, -15, GETDATE()))),
    (52, 8, 59.99, DATEADD(month, -3, DATEADD(day, -12, GETDATE()))),
    (60, 6, 29.99, DATEADD(month, -3, DATEADD(day, -10, GETDATE()))),
    (3, 2, 89.99, DATEADD(month, -3, DATEADD(day, -8, GETDATE()))),
    (12, 5, 29.99, DATEADD(month, -3, DATEADD(day, -5, GETDATE()))),
    (19, 1, 399.99, DATEADD(month, -3, DATEADD(day, -3, GETDATE()))),
    (25, 2, 249.99, DATEADD(month, -3, DATEADD(day, -1, GETDATE()))),

    -- Month 2 ago
    (5, 6, 24.99, DATEADD(month, -2, DATEADD(day, -28, GETDATE()))),
    (14, 2, 349.99, DATEADD(month, -2, DATEADD(day, -25, GETDATE()))),
    (22, 7, 24.99, DATEADD(month, -2, DATEADD(day, -23, GETDATE()))),
    (29, 10, 14.99, DATEADD(month, -2, DATEADD(day, -20, GETDATE()))),
    (37, 3, 199.99, DATEADD(month, -2, DATEADD(day, -18, GETDATE()))),
    (45, 12, 9.99, DATEADD(month, -2, DATEADD(day, -15, GETDATE()))),
    (53, 15, 19.99, DATEADD(month, -2, DATEADD(day, -12, GETDATE()))),
    (61, 8, 34.99, DATEADD(month, -2, DATEADD(day, -10, GETDATE()))),
    (4, 1, 199.99, DATEADD(month, -2, DATEADD(day, -8, GETDATE()))),
    (13, 4, 49.99, DATEADD(month, -2, DATEADD(day, -5, GETDATE()))),
    (20, 3, 79.99, DATEADD(month, -2, DATEADD(day, -3, GETDATE()))),
    (26, 2, 59.99, DATEADD(month, -2, DATEADD(day, -1, GETDATE()))),

    -- Month 1 ago (increasing seasonal trend for certain items)
    (6, 12, 19.99, DATEADD(month, -1, DATEADD(day, -28, GETDATE()))),
    (15, 3, 159.99, DATEADD(month, -1, DATEADD(day, -26, GETDATE()))),
    (23, 5, 29.99, DATEADD(month, -1, DATEADD(day, -24, GETDATE()))),
    (30, 8, 39.99, DATEADD(month, -1, DATEADD(day, -22, GETDATE()))),
    (38, 2, 49.99, DATEADD(month, -1, DATEADD(day, -20, GETDATE()))),
    (46, 6, 39.99, DATEADD(month, -1, DATEADD(day, -18, GETDATE()))),
    (54, 1, 179.99, DATEADD(month, -1, DATEADD(day, -16, GETDATE()))),
    (62, 9, 24.99, DATEADD(month, -1, DATEADD(day, -14, GETDATE()))),
    (5, 5, 24.99, DATEADD(month, -1, DATEADD(day, -12, GETDATE()))),
    (14, 1, 349.99, DATEADD(month, -1, DATEADD(day, -10, GETDATE()))),
    (21, 6, 24.99, DATEADD(month, -1, DATEADD(day, -8, GETDATE()))),
    (27, 2, 179.99, DATEADD(month, -1, DATEADD(day, -6, GETDATE()))),
    (33, 4, 89.99, DATEADD(month, -1, DATEADD(day, -4, GETDATE()))),
    (41, 1, 499.99, DATEADD(month, -1, DATEADD(day, -2, GETDATE()))),

    -- Recent sales (last 30 days, with increasing focus on trending items for data mining)
    (1, 3, 129.99, DATEADD(day, -30, GETDATE())),  -- Gaming peripherals trending up
    (2, 4, 69.99, DATEADD(day, -28, GETDATE())),
    (10, 2, 69.99, DATEADD(day, -27, GETDATE())),  -- Storage trending steadily
    (11, 3, 89.99, DATEADD(day, -25, GETDATE())),
    (35, 5, 99.99, DATEADD(day, -24, GETDATE())),  -- Audio equipment sales increasing
    (36, 3, 119.99, DATEADD(day, -22, GETDATE())),
    (41, 2, 499.99, DATEADD(day, -20, GETDATE())),  -- PC components trending up
    (43, 3, 99.99, DATEADD(day, -19, GETDATE())),
    (7, 4, 39.99, DATEADD(day, -18, GETDATE())),
    (15, 2, 159.99, DATEADD(day, -17, GETDATE())),
    (1, 2, 129.99, DATEADD(day, -16, GETDATE())),  -- Repeat sales showing popularity
    (35, 3, 99.99, DATEADD(day, -15, GETDATE())),
    (18, 3, 299.99, DATEADD(day, -14, GETDATE())),
    (2, 5, 69.99, DATEADD(day, -13, GETDATE())),   -- Wireless mice selling well
    (3, 2, 89.99, DATEADD(day, -12, GETDATE())),
    (10, 4, 69.99, DATEADD(day, -11, GETDATE())),
    (11, 2, 89.99, DATEADD(day, -10, GETDATE())),
    (35, 4, 99.99, DATEADD(day, -9, GETDATE())),   -- Consistent audio equipment sales
    (36, 2, 119.99, DATEADD(day, -8, GETDATE())),
    (41, 1, 499.99, DATEADD(day, -7, GETDATE())),

    -- Last week (with clear emerging trends for BI analysis)
    (1, 5, 129.99, DATEADD(day, -6, GETDATE())),   -- Gaming keyboards spiking
    (2, 7, 69.99, DATEADD(day, -6, GETDATE())),    -- Mice selling alongside keyboards
    (6, 8, 19.99, DATEADD(day, -5, GETDATE())),    -- Mouse pads complementing mice sales
    (35, 6, 99.99, DATEADD(day, -5, GETDATE())),   -- Gaming audio trending with peripherals
    (41, 3, 499.99, DATEADD(day, -4, GETDATE())),  -- Graphics cards spike
    (42, 5, 69.99, DATEADD(day, -4, GETDATE())),   -- CPU coolers following GPU trend
    (43, 4, 99.99, DATEADD(day, -3, GETDATE())),   -- RAM kits trending with other components
    (10, 6, 69.99, DATEADD(day, -3, GETDATE())),   -- Storage sales for new builds
    (11, 5, 89.99, DATEADD(day, -2, GETDATE())),
    (15, 3, 159.99, DATEADD(day, -2, GETDATE())),
    (1, 8, 129.99, DATEADD(day, -1, GETDATE())),   -- Continued strong keyboard sales
    (2, 10, 69.99, DATEADD(day, -1, GETDATE())),   -- Mouse sales increasing further
    (35, 7, 99.99, DATEADD(day, -1, GETDATE())),   -- Audio sales continue strong
    (41, 4, 499.99, DATEADD(day, -1, GETDATE()));  -- Graphics card demand remains high
GO

-- Add more analytics-friendly sales data for trending analysis
INSERT INTO sale (product_id, quantity, sale_price, sale_date)
VALUES
    -- Today's flash sales (to demonstrate real-time analytics capability)
    (1, 12, 119.99, GETDATE()),  -- Discounted keyboards selling rapidly
    (2, 15, 59.99, GETDATE()),   -- Discounted mice selling rapidly
    (6, 20, 17.99, GETDATE()),   -- Discounted mousepads selling rapidly
    (35, 10, 89.99, GETDATE()),  -- Discounted headsets selling rapidly
    (41, 6, 479.99, GETDATE()),  -- Slightly discounted graphics cards still moving
    (10, 8, 64.99, GETDATE()),   -- Storage on sale
    (11, 7, 84.99, GETDATE()),   -- More storage on sale
    (19, 4, 389.99, GETDATE()),  -- Monitor special offer
    (43, 9, 84.99, GETDATE()),   -- RAM kits on promotion
    (57, 14, 34.99, GETDATE()),  -- Cooling pads selling well
    (62, 12, 22.99, GETDATE());  -- Laptop stands on special
GO
