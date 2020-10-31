USE AdventureWorks2012;
GO

/*
	a) Выполните код, созданный во втором задании второй лабораторной работы. 
	   Добавьте в таблицу dbo.StateProvince поля SalesYTD MONEY и SumSales MONEY. 
	   Также создайте в таблице вычисляемое поле SalesPercent, 
	   вычисляющее процентное выражение значения в поле SumSales от значения в поле SalesYTD.
*/
ALTER TABLE dbo.StateProvince
ADD 
	SalesYTD MONEY, 
	SumSales MONEY,
	SalesPercent AS (SumSales / SalesYTD * 100);
GO

/*
	b) Создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID. 
	   Временная таблица должна включать все поля таблицы dbo.StateProvince за исключением поля SalesPercent.
*/
CREATE TABLE #StateProvince
	(
		StateProvinceID INT PRIMARY KEY,
		StateProvinceCode NCHAR(3),
		CountryRegionCode NVARCHAR(3),
		Name NVARCHAR(50),
		TerritoryID INT,
		ModifiedDate DATETIME,
		CountryNum INT,
		SalesYTD MONEY,
		SumSales MONEY
	);
GO

/*
	c) Заполните временную таблицу данными из dbo.StateProvince. 
	   Поле SalesYTD заполните значениями из таблицы Sales.SalesTerritory. 
	   Посчитайте сумму продаж (SalesYTD) для каждой территории (TerritoryID) в таблице Sales.SalesPerson и 
	   заполните этими значениями поле SumSales. 
	   Подсчет суммы продаж осуществите в Common Table Expression (CTE).
*/
WITH SalesSum (TerritoryID, SalesSum)
AS
	(
		SELECT 
			TerritoryID,
			SUM(SalesYTD) as SalesSum
		FROM Sales.SalesPerson
		GROUP BY TerritoryID		
	)
INSERT INTO #StateProvince
SELECT
	dbo.StateProvince.StateProvinceID,
	dbo.StateProvince.StateProvinceCode,
	dbo.StateProvince.CountryRegionCode,
	dbo.StateProvince.Name,
	dbo.StateProvince.TerritoryID,
	dbo.StateProvince.ModifiedDate,
	dbo.StateProvince.CountryNum,
	Sales.SalesTerritory.SalesYTD,
	SalesSum.SalesSum
FROM dbo.StateProvince
	JOIN Sales.SalesTerritory
	ON Sales.SalesTerritory.TerritoryID = dbo.StateProvince.TerritoryID
	JOIN SalesSum
	ON SalesSum.TerritoryID = dbo.StateProvince.TerritoryID;

SELECT *
FROM #StateProvince;

/*
	d) Удалите из таблицы dbo.StateProvince одну строку (где StateProvinceID = 5)
*/
DELETE FROM dbo.StateProvince
WHERE StateProvinceID = 5;

SELECT *
FROM dbo.StateProvince;

/*
	e) Напишите Merge выражение, использующее dbo.StateProvince как target, а временную таблицу как source. 
	   Для связи target и source используйте StateProvinceID. 
	   Обновите поля SalesYTD и SumSales, если запись присутствует в source и target. 
	   Если строка присутствует во временной таблице, но не существует в target, 
	   добавьте строку в dbo.StateProvince. 
	   Если в dbo.StateProvince присутствует такая строка, которой не существует во временной таблице, 
	   удалите строку из dbo.StateProvince.
*/
MERGE dbo.StateProvince AS TargetTable
	USING #StateProvince AS SourceTable
	ON TargetTable.StateProvinceID = SourceTable.StateProvinceID
	WHEN MATCHED THEN
		UPDATE
		SET 
			TargetTable.SalesYTD = SourceTable.SalesYTD,
			TargetTable.SumSales = SourceTable.SumSales
	WHEN NOT MATCHED THEN
		INSERT
		VALUES 
			(
				SourceTable.StateProvinceID,
				SourceTable.StateProvinceCode,
				SourceTable.CountryRegionCode,
				SourceTable.Name,
				SourceTable.TerritoryID,
				SourceTable.ModifiedDate,
				SourceTable.CountryNum,
				SourceTable.SalesYTD,
				SourceTable.SumSales
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

SELECT *
FROM dbo.StateProvince
ORDER BY StateProvinceID;