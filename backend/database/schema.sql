-- Create database if it doesn't exist
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'inventory_management')
BEGIN
    CREATE DATABASE inventory_management;
END
GO

USE inventory_management;
GO

-- Create tables
-- Category table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'category')
BEGIN
    CREATE TABLE category (
        category_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL UNIQUE,
        description VARCHAR(255),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- Product table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'product')
BEGIN
    CREATE TABLE product (
        product_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL,
        category_id INT NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        base_price DECIMAL(10, 2) NOT NULL,
        profit_percentage DECIMAL(10, 2) NOT NULL DEFAULT 30.0,
        quantity INT NOT NULL DEFAULT 0,
        reorder_level INT NOT NULL DEFAULT 10,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (category_id) REFERENCES category(category_id)
    );
END
GO

-- Add profit_percentage and base_price columns if they don't exist (for upgrades)
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE name = 'profit_percentage' AND object_id = OBJECT_ID('product')
)
BEGIN
    ALTER TABLE product
    ADD profit_percentage DECIMAL(10, 2) NOT NULL DEFAULT 30.0;
    
    PRINT 'Added profit_percentage column to product table';
END
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE name = 'base_price' AND object_id = OBJECT_ID('product')
)
BEGIN
    ALTER TABLE product
    ADD base_price DECIMAL(10, 2) NULL;
    
    -- Initialize base_price based on existing price with default profit percentage
    UPDATE product
    SET base_price = price / 1.3
    WHERE base_price IS NULL;
    
    -- Make base_price not nullable after initialization
    ALTER TABLE product
    ALTER COLUMN base_price DECIMAL(10, 2) NOT NULL;
    
    PRINT 'Added base_price column to product table';
END
GO

-- Purchase table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'purchase')
BEGIN
    CREATE TABLE purchase (
        purchase_id INT PRIMARY KEY IDENTITY(1,1),
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        purchase_price DECIMAL(10, 2) NOT NULL,
        supplier VARCHAR(100),
        purchase_date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (product_id) REFERENCES product(product_id)
    );
END
GO

-- Sale table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sale')
BEGIN
    CREATE TABLE sale (
        sale_id INT PRIMARY KEY IDENTITY(1,1),
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        sale_price DECIMAL(10, 2) NOT NULL,
        sale_date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (product_id) REFERENCES product(product_id)
    );
END
GO