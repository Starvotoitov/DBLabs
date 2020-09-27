USE AdventureWorks2012;
GO

/*
	a) создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince, 
	   кроме поля uniqueidentifier, не включая индексы, ограничения и триггеры;
*/
CREATE TABLE dbo.StateProvince
	(
		StateProvinceID INT,
		StateProvinceCode NCHAR(3),
		CountryRegionCode NVARCHAR(3),
		IsOnlyStateProvinceFlag FLAG,
		Name NVARCHAR(50),
		TerritoryID INT,
		ModifiedDate DATETIME
 	);
GO

/*
	b) используя инструкцию ALTER TABLE, 
	   создайте для таблицы dbo.StateProvince ограничение UNIQUE для поля Name;
*/
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT U_Name 
		UNIQUE (Name);
GO

/*
	c) используя инструкцию ALTER TABLE, 
	   создайте для таблицы dbo.StateProvince ограничение для поля CountryRegionCode, 
	   запрещающее заполнение этого поля цифрами;
*/
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT CH_CountryRegionCode 
		CHECK (PATINDEX('%[^0123456789]%', CountryRegionCode) <> 0);
GO

/*
	d) используя инструкцию ALTER TABLE, 
	   создайте для таблицы dbo.StateProvince ограничение DEFAULT для поля ModifiedDate, 
	   задайте значение по умолчанию текущую дату и время;
*/
ALTER TABLE dbo.StateProvince
	ADD CONSTRAINT D_ModifiedDate
		DEFAULT (GETDATE()) FOR ModifiedDate; 
GO

/*
	e) заполните новую таблицу данными из Person.StateProvince. 
	   Выберите для вставки только те данные, 
	   где имя штата/государства совпадает с именем страны/региона в таблице CountryRegion;
*/
INSERT INTO dbo.StateProvince
SELECT 
	Person.StateProvince.StateProvinceID,
	Person.StateProvince.StateProvinceCode,
	Person.StateProvince.CountryRegionCode,
	Person.StateProvince.IsOnlyStateProvinceFlag,
	Person.StateProvince.Name,
	Person.StateProvince.TerritoryID,
	Person.StateProvince.ModifiedDate
FROM Person.StateProvince
	JOIN Person.CountryRegion
	ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE Person.StateProvince.Name = Person.CountryRegion.Name;
GO

/*
	Проверка выполнения задания e
*/
SELECT *
FROM dbo.StateProvince;
GO

/*
	f) удалите поле IsOnlyStateProvinceFlag, 
	   а вместо него создайте новое CountryNum типа int допускающее null значения.
*/
ALTER TABLE dbo.StateProvince
	DROP COLUMN IsOnlyStateProvinceFlag;
ALTER TABLE dbo.StateProvince
	ADD CountryNum INT NULL;
GO

