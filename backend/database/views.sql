-- Views for the inventory management system

USE inventory_management;
GO

-- View for low stock products
IF EXISTS (SELECT * FROM sys.views WHERE name = 'view_low_stock')
    DROP VIEW view_low_stock;
GO

CREATE VIEW view_low_stock AS
SELECT 
    p.product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.quantity,
    p.reorder_level,
    p.price
FROM 
    product p
JOIN 
    category c ON p.category_id = c.category_id
WHERE 
    p.quantity <= p.reorder_level;
GO

-- View for top selling products
IF EXISTS (SELECT * FROM sys.views WHERE name = 'view_top_selling_products')
    DROP VIEW view_top_selling_products;
GO

CREATE VIEW view_top_selling_products AS
SELECT TOP 100
    p.product_id,
    p.name AS product_name,
    c.name AS category_name,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.quantity * s.sale_price) AS total_sales_value
FROM 
    product p
JOIN 
    category c ON p.category_id = c.category_id
JOIN 
    sale s ON p.product_id = s.product_id
GROUP BY 
    p.product_id, p.name, c.name
ORDER BY 
    total_quantity_sold DESC;
GO

-- View for inventory summary
IF EXISTS (SELECT * FROM sys.views WHERE name = 'view_inventory_summary')
    DROP VIEW view_inventory_summary;
GO

CREATE VIEW view_inventory_summary AS
SELECT 
    c.name AS category_name,
    COUNT(p.product_id) AS product_count,
    SUM(p.quantity) AS total_items,
    SUM(p.quantity * p.price) AS total_value
FROM 
    product p
JOIN 
    category c ON p.category_id = c.category_id
GROUP BY 
    c.name;
GO

-- View for recent sales
IF EXISTS (SELECT * FROM sys.views WHERE name = 'view_recent_sales')
    DROP VIEW view_recent_sales;
GO

CREATE VIEW view_recent_sales AS
SELECT TOP 100
    s.sale_id,
    p.name AS product_name,
    s.quantity,
    s.sale_price,
    s.quantity * s.sale_price AS total_amount,
    s.sale_date
FROM
    sale s
JOIN
    product p ON s.product_id = p.product_id
ORDER BY
    s.sale_date DESC;
GO
