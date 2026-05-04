-- ============================================================
-- Create KimberlyEmersonDemos Database
--
-- This script creates a demo database (KimberlyEmersonDemos)
-- and builds a small relational schema using real data copied
-- from AdventureWorks2025. It performs the following steps:
--
-- 1. Creates a fresh demo database and three schemas:
--      - geo (location data)
--      - sales (customer and order data)
--      - production (product data)
--
-- 2. Copies lookup and transactional tables from AdventureWorks
--    into the new database using SELECT...INTO.
--
-- 3. Adds PRIMARY KEY constraints to uniquely identify rows.
--
-- 4. Adds FOREIGN KEY constraints to define relationships
--    between tables (Country → State → Customer → Order → OrderItem).
--
-- The end result is a clean, relational dataset you can use
-- for practicing joins, constraints, and query performance.
-- ============================================================

-- Switch to the master database so we can create or drop other databases
USE master
GO

-- If the demo database already exists, remove it to start fresh
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'KimberlyEmersonDemos')
BEGIN
  DROP DATABASE KimberlyEmersonDemos;
END
GO

-- Create the demo database if it doesn't already exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'KimberlyEmersonDemos')
BEGIN
  CREATE DATABASE KimberlyEmersonDemos;
END
GO

-- Switch into the newly created demo database
USE KimberlyEmersonDemos
GO

-- Create a schema for geographic data
CREATE SCHEMA geo
AUTHORIZATION dbo;
GO

-- Create a schema for sales-related tables
CREATE SCHEMA sales
AUTHORIZATION dbo;
GO

-- Create a schema for product and manufacturing data
CREATE SCHEMA production
AUTHORIZATION dbo;
GO

-- Switch to AdventureWorks so we can copy data from it
USE AdventureWorks2025
GO

-- Copy CountryRegion data into our demo database
SELECT
    cr.CountryRegionCode,
    cr.Name
INTO KimberlyEmersonDemos.geo.CountryRegion
FROM
    Person.CountryRegion cr
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a primary key to uniquely identify each CountryRegion
ALTER TABLE geo.CountryRegion
ADD CONSTRAINT PK_CountryRegion
PRIMARY KEY(CountryRegionCode);
GO

-- Switch to AdventureWorks to pull StateProvince data
USE AdventureWorks2025
GO

-- Copy StateProvince data into our demo database
SELECT
    sp.StateProvinceID,
    sp.StateProvinceCode,
    sp.Name,
    sp.CountryRegionCode,
    sp.ModifiedDate
INTO KimberlyEmersonDemos.geo.StateProvince
FROM
    Person.StateProvince sp;
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a primary key to uniquely identify each StateProvince
ALTER TABLE geo.StateProvince
ADD CONSTRAINT PK_StateProvince
PRIMARY KEY(StateProvinceID);
GO

-- Add a foreign key linking each StateProvince to its CountryRegion
ALTER TABLE geo.StateProvince
ADD CONSTRAINT FK_StateProvince_CountryRegion
FOREIGN KEY(CountryRegionCode)
REFERENCES geo.CountryRegion(CountryRegionCode);
GO

-- Switch to AdventureWorks to pull product data
USE AdventureWorks2025
GO

-- Copy Product data along with category information
SELECT
    p.ProductID,
    Name = p.Name,
    ProductCategory = pc.Name
INTO KimberlyEmersonDemos.production.Product
FROM
    Production.Product p
    INNER JOIN Production.ProductSubcategory psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    INNER JOIN Production.ProductCategory pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a primary key to uniquely identify each Product
ALTER TABLE production.Product
ADD CONSTRAINT PK_Product
PRIMARY KEY (ProductID);
GO

-- Switch to AdventureWorks to pull customer data
USE AdventureWorks2025
GO

-- Copy customer data for customers associated with a store
SELECT  DISTINCT
    CustomerID = c.CustomerID,
    Name = s.Name,
    City = pa.City,
    pa.StateProvinceID
INTO KimberlyEmersonDemos.sales.Customer
FROM
    Sales.Customer c
    INNER JOIN Sales.Store s
        ON c.StoreID = s.BusinessEntityID
    INNER JOIN Person.BusinessEntityAddress bea
        ON s.BusinessEntityID = bea.BusinessEntityID
    INNER JOIN Person.Address pa
        ON bea.AddressID = pa.AddressID
WHERE
    c.StoreID IS NOT NULL
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a primary key to uniquely identify each Customer
ALTER TABLE sales.Customer
ADD CONSTRAINT PK_Customer
PRIMARY KEY (CustomerID);
GO

-- Add a foreign key linking each Customer to their StateProvince
ALTER TABLE sales.Customer
ADD CONSTRAINT FK_Customer_StateProvince
FOREIGN KEY(StateProvinceID)
REFERENCES geo.StateProvince(StateProvinceID);
GO

-- Switch to AdventureWorks to pull order header data
USE AdventureWorks2025
GO

-- Copy order header data for store customers
SELECT
    OrderID = soh.SalesOrderID,
    soh.CustomerID,
    soh.OrderDate,
    TotalAmount = soh.TotalDue
INTO KimberlyEmersonDemos.sales.[Order]
FROM
    Sales.SalesOrderHeader soh
    JOIN Sales.Customer c
        ON soh.CustomerID = c.CustomerID
WHERE
    c.StoreID IS NOT NULL;
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a primary key to uniquely identify each Order
ALTER TABLE sales.[Order]
ADD CONSTRAINT PK_Order
PRIMARY KEY (OrderID);
GO

-- Add a foreign key linking each Order to its Customer
ALTER TABLE sales.[Order]
ADD CONSTRAINT FK_Order_Customer
FOREIGN KEY (CustomerID)
REFERENCES sales.Customer(CustomerID);
GO

-- Switch to AdventureWorks to pull order item data
USE AdventureWorks2025
GO

-- Copy order item data for store customers
SELECT
    OrderItemID = sod.SalesOrderDetailID,
    OrderID = sod.SalesOrderID,
    sod.ProductID,
    Quantity = sod.OrderQty,
    Price = sod.LineTotal
INTO KimberlyEmersonDemos.sales.OrderItem
FROM
    Sales.SalesOrderDetail sod
    INNER JOIN Sales.SalesOrderHeader soh
        ON sod.SalesOrderID = soh.SalesOrderID
    INNER JOIN Sales.Customer c
        ON soh.CustomerID = c.CustomerID
WHERE
    c.StoreID IS NOT NULL;
GO

-- Switch back to our demo database
USE KimberlyEmersonDemos
GO

-- Add a composite primary key because each OrderItem is identified by both OrderItemID and OrderID
ALTER TABLE sales.OrderItem
ADD CONSTRAINT PK_OrderItem
PRIMARY KEY (OrderItemID, OrderID);
GO

-- Add a foreign key linking OrderItem to its Order
ALTER TABLE sales.OrderItem
ADD CONSTRAINT FK_OrderItem_Order
FOREIGN KEY(OrderID)
REFERENCES sales.[Order](OrderID);
GO

-- Add a foreign key linking OrderItem to its Product
ALTER TABLE sales.OrderItem
ADD CONSTRAINT FK_OrderItem_Product
FOREIGN KEY (ProductID)
REFERENCES production.[Product] (ProductID);
GO

-- Modifies Order Date to use most recent years
UPDATE sales.[Order]
SET OrderDate = DATEADD(year, 1, OrderDate);
GO

UPDATE sales.[Order]
SET OrderDate = DATEADD(month, 1, OrderDate);
GO

