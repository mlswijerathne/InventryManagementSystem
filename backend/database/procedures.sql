-- Stored procedures for the inventory management system

USE inventory_management;
GO

-- Procedure to add a new purchase
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_add_purchase')
    DROP PROCEDURE sp_add_purchase;
GO

CREATE PROCEDURE sp_add_purchase
    @product_id INT,
    @quantity INT,
    @purchase_price DECIMAL(10, 2),
    @supplier VARCHAR(100) = NULL,
    @markup_factor DECIMAL(10, 2) = 1.3 -- Default 30% markup
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input
    IF @product_id IS NULL OR @quantity IS NULL OR @purchase_price IS NULL
    BEGIN
        RAISERROR('Product ID, quantity, and purchase price are required.', 16, 1);
        RETURN;
    END;
    
    IF @quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than zero.', 16, 1);
        RETURN;
    END;
    
    IF @purchase_price <= 0
    BEGIN
        RAISERROR('Purchase price must be greater than zero.', 16, 1);
        RETURN;
    END;
    
    -- Check if product exists
    IF NOT EXISTS (SELECT 1 FROM product WHERE product_id = @product_id)
    BEGIN
        RAISERROR('Product does not exist.', 16, 1);
        RETURN;
    END;
    
    -- Insert the purchase
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO purchase (product_id, quantity, purchase_price, supplier, purchase_date)
        VALUES (@product_id, @quantity, @purchase_price, @supplier, GETDATE());
        
        -- Update product quantity and price directly (instead of relying on the trigger)
        UPDATE product
        SET quantity = quantity + @quantity,
            price = @purchase_price * @markup_factor,
            updated_at = GETDATE()
        WHERE product_id = @product_id;
        
        COMMIT TRANSACTION;
        
        -- Return the created purchase_id
        SELECT SCOPE_IDENTITY() AS purchase_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Procedure to make a new sale
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_make_sale')
    DROP PROCEDURE sp_make_sale;
GO

CREATE PROCEDURE sp_make_sale
    @product_id INT,
    @quantity INT,
    @sale_price DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input
    IF @product_id IS NULL OR @quantity IS NULL OR @sale_price IS NULL
    BEGIN
        RAISERROR('Product ID, quantity, and sale price are required.', 16, 1);
        RETURN;
    END;
    
    IF @quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than zero.', 16, 1);
        RETURN;
    END;
    
    IF @sale_price <= 0
    BEGIN
        RAISERROR('Sale price must be greater than zero.', 16, 1);
        RETURN;
    END;
    
    -- Check if product exists
    IF NOT EXISTS (SELECT 1 FROM product WHERE product_id = @product_id)
    BEGIN
        RAISERROR('Product does not exist.', 16, 1);
        RETURN;
    END;
    
    -- Check if there's enough stock
    DECLARE @current_stock INT;
    SELECT @current_stock = quantity FROM product WHERE product_id = @product_id;
    
    IF @current_stock < @quantity
    BEGIN
        RAISERROR('Not enough stock available. Current stock: %d, Requested: %d', 16, 1, @current_stock, @quantity);
        RETURN;
    END;
    
    -- Insert the sale
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO sale (product_id, quantity, sale_price, sale_date)
        VALUES (@product_id, @quantity, @sale_price, GETDATE());
        
        -- The trigger trg_update_stock_on_sale will update the product quantity
        
        COMMIT TRANSACTION;
        
        -- Return the created sale_id
        SELECT SCOPE_IDENTITY() AS sale_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Procedure to get product details with stock status
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_get_product_details')
    DROP PROCEDURE sp_get_product_details;
GO

CREATE PROCEDURE sp_get_product_details
    @product_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
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
        END AS stock_status,
        p.created_at,
        p.updated_at
    FROM 
        product p
    JOIN 
        category c ON p.category_id = c.category_id
    WHERE 
        (@product_id IS NULL OR p.product_id = @product_id)
    ORDER BY 
        p.name;
END;
GO

-- Procedure to get sales history for a product
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_get_product_sales_history')
    DROP PROCEDURE sp_get_product_sales_history;
GO

CREATE PROCEDURE sp_get_product_sales_history
    @product_id INT,
    @start_date DATETIME = NULL,
    @end_date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Set default date range if not provided
    IF @start_date IS NULL
        SET @start_date = DATEADD(MONTH, -3, GETDATE());
        
    IF @end_date IS NULL
        SET @end_date = GETDATE();
    
    -- Get sales history
    SELECT 
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
    WHERE 
        s.product_id = @product_id
        AND s.sale_date BETWEEN @start_date AND @end_date
    ORDER BY 
        s.sale_date DESC;
END;
GO
-- Create user-defined table type for batch stock updates
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'ProductStockUpdateType' AND is_table_type = 1)
BEGIN
    CREATE TYPE dbo.ProductStockUpdateType AS TABLE
    (
        product_id INT NOT NULL,
        quantity_change INT NOT NULL,
        reason VARCHAR(255) NULL
    );
END;
GO

-- Procedure to batch update product stock
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_batch_update_stock')
    DROP PROCEDURE sp_batch_update_stock;
GO

CREATE PROCEDURE sp_batch_update_stock
    @product_updates dbo.ProductStockUpdateType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    -- Validate input data
    IF EXISTS (
        SELECT 1 FROM @product_updates 
        WHERE product_id IS NULL OR quantity_change IS NULL OR quantity_change = 0
    )
    BEGIN
        RAISERROR('All product IDs and quantity changes are required and must not be zero.', 16, 1);
        RETURN;
    END;
    
    -- Check if all products exist
    IF EXISTS (
        SELECT pu.product_id
        FROM @product_updates pu
        LEFT JOIN product p ON pu.product_id = p.product_id
        WHERE p.product_id IS NULL
    )
    BEGIN
        SET @ErrorMessage = 'One or more products do not exist.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END;
    
    -- Check that we have enough stock for negative adjustments
    IF EXISTS (
        SELECT 1
        FROM @product_updates pu
        JOIN product p ON pu.product_id = p.product_id
        WHERE pu.quantity_change < 0 AND ABS(pu.quantity_change) > p.quantity
    )
    BEGIN
        SET @ErrorMessage = 'One or more products do not have enough stock for the requested reduction.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END;
    
    -- Update all product quantities in a single transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE p
        SET p.quantity = p.quantity + pu.quantity_change,
            p.updated_at = GETDATE()
        FROM product p
        JOIN @product_updates pu ON p.product_id = pu.product_id;
        
        COMMIT TRANSACTION;
        
        -- Return updated products
        SELECT 
            p.product_id,
            p.name,
            p.quantity AS updated_quantity,
            p.reorder_level,
            CASE 
                WHEN p.quantity <= p.reorder_level AND p.quantity > 0 THEN 'Low Stock'
                WHEN p.quantity = 0 THEN 'Out of Stock'
                ELSE 'In Stock'
            END AS stock_status,
            pu.quantity_change,
            pu.reason
        FROM 
            product p
        JOIN 
            @product_updates pu ON p.product_id = pu.product_id
        ORDER BY 
            p.name;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ErrorMessage = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Procedure to generate stock level report
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_generate_stock_level_report')
    DROP PROCEDURE sp_generate_stock_level_report;
GO

CREATE PROCEDURE sp_generate_stock_level_report
    @category_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.category_id,
        c.name AS category_name,
        COUNT(p.product_id) AS total_products,
        SUM(p.quantity) AS total_stock,
        SUM(CASE WHEN p.quantity <= p.reorder_level AND p.quantity > 0 THEN 1 ELSE 0 END) AS low_stock_count,
        SUM(CASE WHEN p.quantity = 0 THEN 1 ELSE 0 END) AS out_of_stock_count,
        SUM(CASE WHEN p.quantity > p.reorder_level THEN 1 ELSE 0 END) AS healthy_stock_count,
        SUM(p.quantity * p.price) AS total_stock_value
    FROM 
        category c
    LEFT JOIN 
        product p ON c.category_id = p.category_id
    WHERE 
        (@category_id IS NULL OR c.category_id = @category_id)
    GROUP BY 
        c.category_id, c.name
    ORDER BY 
        c.name;
END;
GO

-- Procedure to forecast stock needs based on historical sales
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_forecast_stock_needs')
    DROP PROCEDURE sp_forecast_stock_needs;
GO

CREATE PROCEDURE sp_forecast_stock_needs
    @product_id INT = NULL,
    @days_to_forecast INT = 30,
    @lookback_days INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_date DATETIME = DATEADD(DAY, -@lookback_days, GETDATE());
    
    -- Calculate average daily sales for each product
    WITH product_sales AS (
        SELECT 
            p.product_id,
            p.name AS product_name,
            p.category_id,
            c.name AS category_name,
            p.quantity AS current_stock,
            p.reorder_level,
            SUM(s.quantity) AS total_sales,
            COUNT(DISTINCT CAST(s.sale_date AS DATE)) AS days_with_sales,
            CASE 
                WHEN COUNT(DISTINCT CAST(s.sale_date AS DATE)) = 0 THEN 0 
                ELSE SUM(s.quantity) / COUNT(DISTINCT CAST(s.sale_date AS DATE)) 
            END AS avg_daily_sales
        FROM 
            product p
        LEFT JOIN 
            sale s ON p.product_id = s.product_id AND s.sale_date >= @start_date
        JOIN 
            category c ON p.category_id = c.category_id
        WHERE 
            (@product_id IS NULL OR p.product_id = @product_id)
        GROUP BY 
            p.product_id, p.name, p.category_id, c.name, p.quantity, p.reorder_level
    )
    
    -- Calculate forecast
    SELECT 
        product_id,
        product_name,
        category_name,
        current_stock,
        reorder_level,
        CEILING(avg_daily_sales) AS estimated_daily_usage,
        CASE 
            WHEN avg_daily_sales = 0 THEN NULL 
            ELSE FLOOR(current_stock / NULLIF(avg_daily_sales, 0)) 
        END AS estimated_days_remaining,
        CASE 
            WHEN avg_daily_sales = 0 THEN 0 
            ELSE CEILING(avg_daily_sales * @days_to_forecast) 
        END AS projected_usage_30d,
        CASE 
            WHEN current_stock - (avg_daily_sales * @days_to_forecast) < 0 THEN 
                CEILING(ABS(current_stock - (avg_daily_sales * @days_to_forecast)))
            ELSE 0 
        END AS suggested_purchase_quantity,
        CASE 
            WHEN current_stock <= reorder_level AND current_stock > 0 THEN 'Low Stock'
            WHEN current_stock = 0 THEN 'Out of Stock'
            WHEN avg_daily_sales > 0 AND current_stock / avg_daily_sales < 15 THEN 'Order Soon'
            ELSE 'In Stock'
        END AS stock_status
    FROM 
        product_sales
    ORDER BY 
        CASE 
            WHEN current_stock = 0 THEN 1
            WHEN current_stock <= reorder_level THEN 2
            WHEN avg_daily_sales > 0 AND current_stock / NULLIF(avg_daily_sales, 0) < 15 THEN 3
            ELSE 4
        END,
        product_name;
END;
GO
-- Procedure to get stock expiration alerts
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_get_stock_expiration_alerts')
    DROP PROCEDURE sp_get_stock_expiration_alerts;
GO

CREATE PROCEDURE sp_get_stock_expiration_alerts
    @days_warning INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    -- First, let's add an expiration_date column to the purchase table if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE name = 'expiration_date' 
        AND object_id = OBJECT_ID('purchase')
    )
    BEGIN
        ALTER TABLE purchase
        ADD expiration_date DATE NULL;
        
        PRINT 'Added expiration_date column to purchase table.';
    END;
    
    DECLARE @warning_date DATE = DATEADD(DAY, @days_warning, GETDATE());
    
    SELECT 
        p.product_id,
        pr.name AS product_name,
        c.name AS category_name,
        SUM(p.quantity) AS expiring_quantity,
        MIN(p.expiration_date) AS earliest_expiration,
        DATEDIFF(DAY, GETDATE(), MIN(p.expiration_date)) AS days_until_expiration,
        CASE
            WHEN MIN(p.expiration_date) <= GETDATE() THEN 'Expired'
            WHEN MIN(p.expiration_date) <= @warning_date THEN 'Expiring Soon'
            ELSE 'OK'
        END AS status
    FROM 
        purchase p
    JOIN 
        product pr ON p.product_id = pr.product_id
    JOIN 
        category c ON pr.category_id = c.category_id
    WHERE 
        p.expiration_date IS NOT NULL
        AND p.expiration_date <= @warning_date
    GROUP BY 
        p.product_id, pr.name, c.name
    ORDER BY 
        days_until_expiration ASC;
END;
GO

-- Procedure to set product expiration dates
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_set_purchase_expiration')
    DROP PROCEDURE sp_set_purchase_expiration;
GO

CREATE PROCEDURE sp_set_purchase_expiration
    @purchase_id INT,
    @expiration_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input
    IF @purchase_id IS NULL OR @expiration_date IS NULL
    BEGIN
        RAISERROR('Purchase ID and expiration date are required.', 16, 1);
        RETURN;
    END;
    
    -- Check if purchase exists
    IF NOT EXISTS (SELECT 1 FROM purchase WHERE purchase_id = @purchase_id)
    BEGIN
        RAISERROR('Purchase does not exist.', 16, 1);
        RETURN;
    END;
    
    -- Update the expiration date
    BEGIN TRY
        UPDATE purchase
        SET expiration_date = @expiration_date
        WHERE purchase_id = @purchase_id;
        
        -- Return updated purchase info
        SELECT 
            p.purchase_id,
            pr.name AS product_name,
            p.quantity,
            p.purchase_price,
            p.purchase_date,
            p.expiration_date,
            DATEDIFF(DAY, GETDATE(), p.expiration_date) AS days_until_expiration
        FROM 
            purchase p
        JOIN 
            product pr ON p.product_id = pr.product_id
        WHERE 
            p.purchase_id = @purchase_id;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Procedure to analyze product performance
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_analyze_product_performance')
    DROP PROCEDURE sp_analyze_product_performance;
GO

CREATE PROCEDURE sp_analyze_product_performance
    @lookback_days INT = 90,
    @category_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_date DATETIME = DATEADD(DAY, -@lookback_days, GETDATE());
    
    WITH product_metrics AS (
        SELECT 
            p.product_id,
            p.name AS product_name,
            c.name AS category_name,
            p.price,
            p.quantity AS current_stock,
            COUNT(s.sale_id) AS sale_count,
            ISNULL(SUM(s.quantity), 0) AS units_sold,
            ISNULL(SUM(s.quantity * s.sale_price), 0) AS total_revenue,
            ISNULL(SUM(s.quantity * s.sale_price) / NULLIF(SUM(s.quantity), 0), 0) AS avg_unit_price
        FROM 
            product p
        LEFT JOIN 
            sale s ON p.product_id = s.product_id AND s.sale_date >= @start_date
        JOIN 
            category c ON p.category_id = c.category_id
        WHERE
            (@category_id IS NULL OR p.category_id = @category_id)
        GROUP BY 
            p.product_id, p.name, c.name, p.price, p.quantity
    )
    
    SELECT 
        pm.*,
        CASE 
            WHEN pm.units_sold > 0 THEN
                RANK() OVER (ORDER BY pm.units_sold DESC)
            ELSE NULL
        END AS unit_sales_rank,
        CASE 
            WHEN pm.total_revenue > 0 THEN
                RANK() OVER (ORDER BY pm.total_revenue DESC)
            ELSE NULL
        END AS revenue_rank,
        CASE
            WHEN pm.units_sold = 0 THEN 'Non-Moving'
            WHEN pm.units_sold <= 5 THEN 'Slow-Moving'
            WHEN pm.units_sold > 20 THEN 'Fast-Moving'
            ELSE 'Medium-Moving'
        END AS inventory_velocity,
        CASE
            WHEN pm.current_stock = 0 THEN 'Out of Stock'
            WHEN pm.units_sold = 0 THEN 'Overstocked'
            WHEN pm.current_stock / (pm.units_sold / @lookback_days) > 60 THEN 'Overstocked'
            WHEN pm.current_stock / (pm.units_sold / @lookback_days) < 7 THEN 'Understocked'
            ELSE 'Optimally Stocked'
        END AS stock_efficiency
    FROM 
        product_metrics pm
    ORDER BY 
        pm.total_revenue DESC;
END;
GO

-- Procedure for automatic reorder suggestions
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_generate_reorder_suggestions')
    DROP PROCEDURE sp_generate_reorder_suggestions;
GO

CREATE PROCEDURE sp_generate_reorder_suggestions
    @lookback_days INT = 90,
    @forecast_days INT = 30,
    @safety_stock_days INT = 15,
    @lead_time_days INT = 7
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_date DATETIME = DATEADD(DAY, -@lookback_days, GETDATE());
    
    -- Calculate reorder suggestions based on historical usage
    WITH product_usage AS (
        SELECT 
            p.product_id,
            p.name AS product_name,
            c.name AS category_name,
            p.quantity AS current_stock,
            p.reorder_level,
            p.price,
            ISNULL(SUM(s.quantity), 0) AS total_sold,
            CASE 
                WHEN COUNT(DISTINCT CAST(s.sale_date AS DATE)) = 0 THEN 0
                ELSE ISNULL(SUM(s.quantity), 0) / COUNT(DISTINCT CAST(s.sale_date AS DATE))
            END AS daily_usage
        FROM 
            product p
        LEFT JOIN 
            sale s ON p.product_id = s.product_id AND s.sale_date >= @start_date
        JOIN 
            category c ON p.category_id = c.category_id
        GROUP BY 
            p.product_id, p.name, c.name, p.quantity, p.reorder_level, p.price
    )
    
    SELECT 
        pu.product_id,
        pu.product_name,
        pu.category_name,
        pu.current_stock,
        pu.reorder_level,
        CAST(pu.daily_usage AS DECIMAL(10,2)) AS daily_usage,
        CAST(pu.daily_usage * @forecast_days AS INT) AS forecast_usage,
        CAST(pu.daily_usage * @safety_stock_days AS INT) AS safety_stock,
        CAST(pu.daily_usage * @lead_time_days AS INT) AS lead_time_usage,
        CASE
            WHEN pu.daily_usage > 0 THEN
                CAST(pu.daily_usage * (@forecast_days + @safety_stock_days + @lead_time_days) AS INT)
            ELSE pu.reorder_level
        END AS suggested_reorder_point,
        CASE
            WHEN pu.current_stock <= pu.reorder_level THEN
                CASE
                    WHEN pu.daily_usage > 0 THEN
                        CAST(pu.daily_usage * (@forecast_days + @safety_stock_days) - pu.current_stock AS INT)
                    ELSE pu.reorder_level
                END
            ELSE 0
        END AS suggested_order_quantity,
        CASE
            WHEN pu.current_stock <= pu.reorder_level THEN 'Reorder Now'
            WHEN pu.current_stock <= CAST(pu.daily_usage * (@forecast_days + @safety_stock_days + @lead_time_days) AS INT) THEN 'Reorder Soon'
            ELSE 'Stock Adequate'
        END AS reorder_status
    FROM 
        product_usage pu
    ORDER BY 
        CASE
            WHEN pu.current_stock <= pu.reorder_level THEN 1
            WHEN pu.current_stock <= CAST(pu.daily_usage * (@forecast_days + @safety_stock_days + @lead_time_days) AS INT) THEN 2
            ELSE 3
        END,
        pu.product_name;
END;
GO
