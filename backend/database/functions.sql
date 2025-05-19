-- SQL Functions for the inventory management system

USE inventory_management;
GO

-- Function to calculate total sales for a product
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.fn_total_sales') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.fn_total_sales;
GO

CREATE FUNCTION dbo.fn_total_sales(@product_id INT)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @total_sales DECIMAL(12, 2);
    
    SELECT @total_sales = ISNULL(SUM(quantity * sale_price), 0)
    FROM sale
    WHERE product_id = @product_id;
    
    RETURN @total_sales;
END;
GO

-- Function to calculate total inventory value
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.fn_inventory_value') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.fn_inventory_value;
GO

CREATE FUNCTION dbo.fn_inventory_value()
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @total_value DECIMAL(12, 2);
    
    SELECT @total_value = ISNULL(SUM(quantity * price), 0)
    FROM product;
    
    RETURN @total_value;
END;
GO

-- Function to calculate product profit margin
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.fn_product_profit_margin') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.fn_product_profit_margin;
GO

CREATE FUNCTION dbo.fn_product_profit_margin(@product_id INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @avg_purchase_price DECIMAL(10, 2);
    DECLARE @avg_sale_price DECIMAL(10, 2);
    DECLARE @profit_margin DECIMAL(5, 2);
    
    -- Calculate average purchase price
    SELECT @avg_purchase_price = AVG(purchase_price)
    FROM purchase
    WHERE product_id = @product_id;
    
    -- Calculate average sale price
    SELECT @avg_sale_price = AVG(sale_price)
    FROM sale
    WHERE product_id = @product_id;
    
    -- Calculate profit margin
    IF @avg_purchase_price IS NULL OR @avg_purchase_price = 0 OR @avg_sale_price IS NULL
        SET @profit_margin = 0;
    ELSE
        SET @profit_margin = ((@avg_sale_price - @avg_purchase_price) / @avg_purchase_price) * 100;
    
    RETURN @profit_margin;
END;
GO

-- Function to get products by stock status
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.fn_get_products_by_stock_status') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.fn_get_products_by_stock_status;
GO

CREATE FUNCTION dbo.fn_get_products_by_stock_status(@status VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.product_id,
        p.name AS product_name,
        c.name AS category_name,
        p.price,
        p.quantity AS current_stock,
        p.reorder_level,
        CASE 
            WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
            WHEN p.quantity = 0 THEN 'Out of Stock'
            ELSE 'In Stock'
        END AS stock_status
    FROM 
        product p
    JOIN 
        category c ON p.category_id = c.category_id
    WHERE 
        CASE 
            WHEN p.quantity <= p.reorder_level THEN 'Low Stock'
            WHEN p.quantity = 0 THEN 'Out of Stock'
            ELSE 'In Stock'
        END = @status
);
GO

-- Function to calculate sales trend (% change) for a product
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.fn_sales_trend') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.fn_sales_trend;
GO

CREATE FUNCTION dbo.fn_sales_trend(@product_id INT, @days_prior INT = 30)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @current_period_sales DECIMAL(12, 2);
    DECLARE @previous_period_sales DECIMAL(12, 2);
    DECLARE @trend_percentage DECIMAL(5, 2);
    
    -- Calculate current period sales (last @days_prior days)
    SELECT @current_period_sales = ISNULL(SUM(quantity * sale_price), 0)
    FROM sale
    WHERE 
        product_id = @product_id
        AND sale_date BETWEEN DATEADD(DAY, -@days_prior, GETDATE()) AND GETDATE();
    
    -- Calculate previous period sales (previous @days_prior days)
    SELECT @previous_period_sales = ISNULL(SUM(quantity * sale_price), 0)
    FROM sale
    WHERE 
        product_id = @product_id
        AND sale_date BETWEEN DATEADD(DAY, -(@days_prior * 2), GETDATE()) AND DATEADD(DAY, -@days_prior, GETDATE());
    
    -- Calculate trend percentage
    IF @previous_period_sales IS NULL OR @previous_period_sales = 0
        SET @trend_percentage = 100; -- If no previous sales, consider it as 100% growth
    ELSE
        SET @trend_percentage = ((@current_period_sales - @previous_period_sales) / @previous_period_sales) * 100;
    
    RETURN @trend_percentage;
END;
GO
