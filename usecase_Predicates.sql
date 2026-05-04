SELECT
	c.CustomerID,
	c.Name,
	c.City
FROM
	sales.Customer c
WHERE
	c.CustomerID = 755;
GO