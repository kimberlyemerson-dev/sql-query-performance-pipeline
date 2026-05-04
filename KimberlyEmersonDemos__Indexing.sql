USE KimberlyEmersonDemos
GO

CREATE INDEX IX_CountryRegion_CountryRegionCode_Covering
ON geo.CountryRegion (CountryRegionCode)
INCLUDE (Name);
GO

CREATE INDEX IX_StateProvince_CountryRegionCode
ON geo.StateProvince (CountryRegionCode)
INCLUDE (StateProvinceCode, Name);
GO

CREATE INDEX IX_Product_ProductCategory_Covering
ON production.Product (ProductCategory)
INCLUDE (ProductID, Name);
GO

CREATE INDEX IX_Customer_City_Covering
ON sales.Customer (City)
INCLUDE (CustomerID, Name);
GO

CREATE INDEX IX_Order_CustomerID_Covering
ON sales.[Order] (CustomerID)
INCLUDE (OrderDate, TotalAmount, OrderID);
GO

CREATE NONCLUSTERED INDEX IX_OrderItem_Quantity_Covering 
ON [sales].[OrderItem] ([Quantity]) 
INCLUDE ([ProductID],[Price]);
GO
