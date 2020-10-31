USE AdventureWorks2012;
GO

/* 
	a) Добавьте в таблицу dbo.StateProvince поле CountryRegionName типа nvarchar(50)
*/
ALTER TABLE dbo.StateProvince
	ADD CountryRegionName NVARCHAR(50);
GO

/*
	b) Объявите табличную переменную с такой же структурой как dbo.StateProvince и 
	   заполните ее данными из dbo.StateProvince.
	   Заполните поле CountryRegionName данными из Person.CountryRegion поля Name
*/
DECLARE @StateProvinceTableVar 
TABLE
	(
		StateProvinceID INT,
		StateProvinceCode NCHAR(3),
		CountryRegionCode NVARCHAR(3),
		Name NVARCHAR(50),
		TerritoryID INT,
		ModifiedDate DATETIME,
		CountryNum INT,
		CountryRegionName NVARCHAR(50)
	);

INSERT INTO @StateProvinceTableVar
SELECT 
	Province.StateProvinceID,
	Province.StateProvinceCode,
	Province.CountryRegionCode,
	Province.Name,
	Province.TerritoryID,
	Province.ModifiedDate,
	Province.CountryNum,
	Region.Name
FROM dbo.StateProvince AS Province
	JOIN Person.CountryRegion AS Region
	ON Province.CountryRegionCode = Region.CountryRegionCode;

SELECT *
FROM @StateProvinceTableVar;

/*
	c) Обновите поле CountryRegionName в dbo.StateProvince данными из табличной переменной
*/
UPDATE dbo.StateProvince
SET CountryRegionName = Source.CountryRegionName
FROM @StateProvinceTableVar as Source
WHERE dbo.StateProvince.StateProvinceID = Source.StateProvinceID;
GO

SELECT *
FROM dbo.StateProvince;
GO

/*
	d) Удалите штаты из dbo.StateProvince, которые отсутствуют в таблице Person.Address
*/
DELETE FROM dbo.StateProvince
WHERE StateProvinceID NOT IN 
	(
		SELECT 
			StateProvinceID
		FROM Person.Address
	);
GO

SELECT *
FROM dbo.StateProvince;
GO

/*
	e) Удалите поле CountryRegionName из таблицы, удалите все созданные ограничения и значения по умолчанию.
	   Имена ограничений вы можете найти в метаданных.
	   Имена значений по умолчанию найдите самостоятельно, приведите код, которым пользовались для поиска.
*/
SELECT sys.objects.name
FROM sys.tables
	JOIN sys.objects
	ON sys.tables.object_id = sys.objects.parent_object_id
WHERE sys.tables.name = 'StateProvince' AND sys.tables.schema_id = schema_id('dbo');

ALTER TABLE dbo.StateProvince
DROP COLUMN CountryRegionName;

ALTER TABLE dbo.StateProvince
DROP CONSTRAINT U_Name, CH_CountryRegionCode, D_ModifiedDate;

/*
	f) Удалите таблицу dbo.StateProvince
*/
DROP TABLE dbo.StateProvince;