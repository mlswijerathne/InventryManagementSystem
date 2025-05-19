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
