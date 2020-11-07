USE AdventureWorks2012;
GO

/*
	a) Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра 
	   id заказа (Sales.SalesOrderHeader.SalesOrderID) и 
	   возвращать максимальную цену продукта из заказа (Sales.SalesOrderDetail.UnitPrice).
*/
CREATE FUNCTION Sales.getMaxUnitPrice 
	(
		@id INT
	)
RETURNS MONEY
AS
BEGIN
	RETURN
		(
			SELECT 
				MAX(Detail.UnitPrice) AS MaxUnitPrice
			FROM Sales.SalesOrderDetail AS Detail
			WHERE Detail.SalesOrderID = @id
			GROUP BY Detail.SalesOrderID
		);
END;
GO

/*
	b) Создайте inline table-valued функцию, которая будет принимать в качестве входных параметров 
	   id продукта (Production.Product.ProductID) и количество строк, которые необходимо вывести.
	   Функция должна возвращать определенное количество инвентаризационных записей о продукте 
	   с наибольшим его количеством (по Quantity) из Production.ProductInventory. 
	   Функция должна возвращать только продукты, хранящиеся в отделе А (Production.ProductInventory.Shelf).
*/
CREATE FUNCTION Production.getInventoryRecords
	(
		@id INT,
		@count INT
	)
RETURNS TABLE
AS
RETURN
	(
		SELECT TOP(@count)
			*
		FROM Production.ProductInventory AS Inventory
		WHERE 
			Inventory.Shelf = 'A' AND 
			Inventory.ProductID = @id
		ORDER BY
			Quantity DESC
	);
GO

/*
	c) Вызовите функцию для каждого продукта, применив оператор CROSS APPLY. 
	   
*/
SELECT
	Records.*
FROM Production.Product AS Prod
	CROSS APPLY Production.getInventoryRecords(Prod.ProductID, 1) AS Records
ORDER BY Prod.ProductID;

/*
	d) Вызовите функцию для каждого продукта, применив оператор OUTER APPLY.
*/
SELECT
	Records.*
FROM Production.Product AS Prod
	OUTER APPLY Production.getInventoryRecords(Prod.ProductID, 1) AS Records
ORDER BY Prod.ProductID;
GO

/*
	e) Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
	   (предварительно сохранив для проверки код создания inline table-valued функции).
*/
DROP FUNCTION Production.getInventoryRecords;
GO

CREATE FUNCTION Production.getInventoryRecords
	(
		@id INT,
		@count INT
	)
RETURNS @inventoryRecords TABLE
	(
		ProductID INT,
		LocationID SMALLINT,
		Shelf NVARCHAR(10),
		Bin TINYINT,
		Quantity SMALLINT,
		rowguid UNIQUEIDENTIFIER,
		ModifiedDate DATETIME
	)
AS
BEGIN
	INSERT INTO @inventoryRecords
	SELECT TOP(@count)
		*
	FROM Production.ProductInventory AS Inventory
	WHERE 
		Inventory.Shelf = 'A' AND 
		Inventory.ProductID = @id
	ORDER BY
		Quantity DESC
	RETURN
END;
GO