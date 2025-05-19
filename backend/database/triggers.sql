-- Triggers for the inventory management system

USE inventory_management;
GO

-- Trigger to update product quantity and price when a purchase is made
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_update_stock_on_purchase')
    DROP TRIGGER trg_update_stock_on_purchase;
GO

CREATE TRIGGER trg_update_stock_on_purchase
ON purchase
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update product quantity and price based on the new purchase price
    -- This will add a markup of 30% to the purchase price to set as the new selling price
    UPDATE p
    SET p.quantity = p.quantity + i.quantity,
        p.price = i.purchase_price * 1.3, -- 30% markup on purchase price
        p.updated_at = GETDATE()
    FROM product p
    INNER JOIN inserted i ON p.product_id = i.product_id;
END;
GO

-- Trigger to update product quantity when a sale is made
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_update_stock_on_sale')
    DROP TRIGGER trg_update_stock_on_sale;
GO

CREATE TRIGGER trg_update_stock_on_sale
ON sale
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update product quantity
    UPDATE p
    SET p.quantity = p.quantity - i.quantity,
        p.updated_at = GETDATE()
    FROM product p
    INNER JOIN inserted i ON p.product_id = i.product_id;
    
    -- Check for low stock after sale
    DECLARE @low_stock_products TABLE (
        product_id INT,
        product_name VARCHAR(100),
        current_quantity INT,
        reorder_level INT
    );
    
    INSERT INTO @low_stock_products
    SELECT p.product_id, p.name, p.quantity, p.reorder_level
    FROM product p
    INNER JOIN inserted i ON p.product_id = i.product_id
    WHERE p.quantity <= p.reorder_level;
    
    -- Here you could send alerts or log low stock status
    -- For demonstration, we'll just print messages
    DECLARE @product_id INT, @product_name VARCHAR(100), @quantity INT, @reorder_level INT;
    
    DECLARE low_stock_cursor CURSOR FOR
    SELECT product_id, product_name, current_quantity, reorder_level
    FROM @low_stock_products;
    
    OPEN low_stock_cursor;
    
    FETCH NEXT FROM low_stock_cursor INTO @product_id, @product_name, @quantity, @reorder_level;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'LOW STOCK ALERT: Product ' + @product_name + ' is low on stock. Current quantity: ' + 
              CAST(@quantity AS VARCHAR) + ', Reorder level: ' + CAST(@reorder_level AS VARCHAR);
        
        FETCH NEXT FROM low_stock_cursor INTO @product_id, @product_name, @quantity, @reorder_level;
    END;
    
    CLOSE low_stock_cursor;
    DEALLOCATE low_stock_cursor;
END;
GO

-- Trigger to update product's updated_at timestamp when modified
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_product_update_timestamp')
    DROP TRIGGER trg_product_update_timestamp;
GO

CREATE TRIGGER trg_product_update_timestamp
ON product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(name) OR UPDATE(category_id) OR UPDATE(price) OR UPDATE(quantity) OR UPDATE(reorder_level)
    BEGIN
        UPDATE p
        SET p.updated_at = GETDATE()
        FROM product p
        INNER JOIN inserted i ON p.product_id = i.product_id;
    END;
END;
GO
