USE KimberlyEmersonDemos
GO

SELECT 
	c.CustomerID, 
	c.Name, 
	o.OrderID, 
	o.OrderDate,
	o.TotalAmount
FROM 
	sales.Customer c
	INNER JOIN sales.[Order] o 
		ON o.CustomerID = c.CustomerID
WHERE 
	c.City = 'Houston'
	AND o.TotalAmount > 10000
	AND o.OrderDate >= DATEADD(day, -30, GETDATE());
GO