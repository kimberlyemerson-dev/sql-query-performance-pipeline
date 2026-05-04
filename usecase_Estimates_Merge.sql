USE KimberlyEmersonDemos
GO

SELECT 
    o.OrderID,
    o.OrderDate,
    oi.ProductID,
    oi.Quantity,
    oi.Price
FROM 
    sales.[Order] o
    INNER JOIN sales.OrderItem oi
        ON o.OrderID = oi.OrderID
ORDER BY
    o.OrderID;
GO