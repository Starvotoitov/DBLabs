USE AdventureWorks2012;
GO

/*
	a) Создайте представление VIEW, отображающее данные из таблиц Production.ProductModel, 
	   Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription. 
	   Сделайте невозможным просмотр исходного кода представления. 
	   Создайте уникальный кластерный индекс в представлении по полям ProductModelID,CultureID.
*/
CREATE VIEW Production.ProductModelProductDescriptionCultureView
	WITH ENCRYPTION, SCHEMABINDING
AS
	SELECT 
		Model.ProductModelID,
		Description.ProductDescriptionID,
		Culture.CultureID,
		UnionTable.ProductModelID AS UnionProductModelID,
		UnionTable.ProductDescriptionID AS UnionDescriptionID,
		UnionTable.CultureID AS UnionCultureID,
		UnionTable.ModifiedDate AS ProductModelProductDescriptionCultureModifiedDate,
		Model.Name AS ProductModelName,
		Model.CatalogDescription,
		Model.Instructions,
		Model.rowguid AS ProductModelRowguid,
		Model.ModifiedDate AS ProductModelModifiedDate,
		Culture.Name AS CultureName,
		Culture.ModifiedDate AS CultureModifiedDate,
		Description.Description,
		Description.rowguid AS ProductDescriptionRowguid,
		Description.ModifiedDate AS ProductDescriptionModifiedDate
	FROM Production.ProductModelProductDescriptionCulture AS UnionTable
		JOIN Production.ProductModel AS Model
		ON UnionTable.ProductModelID = Model.ProductModelID
		JOIN Production.Culture AS Culture
		ON UnionTable.CultureID = Culture.CultureID
		JOIN Production.ProductDescription AS Description
		ON UnionTable.ProductDescriptionID = Description.ProductDescriptionID;
GO

CREATE UNIQUE CLUSTERED INDEX I_ProductModelID_CultureID
ON Production.ProductModelProductDescriptionCultureView 
	(
		ProductModelID,
		CultureID
	);
GO

/*
	b) Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. 
	   Каждый триггер должен выполнять соответствующие операции в таблицах Production.ProductModel, 
	   Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription. 
	   Обновление не должно происходить в таблице Production.ProductModelProductDescriptionCulture. 
	   Удаление строк из таблиц Production.ProductModel, Production.Culture и Production.ProductDescription производите только в том случае, 
	   если удаляемые строки больше не ссылаются на Production.ProductModelProductDescriptionCulture.
*/
CREATE TRIGGER Instead_of_Insert
	ON Production.ProductModelProductDescriptionCultureView
	INSTEAD OF INSERT
AS
	DECLARE @ProductModelIDTable
	TABLE
		(
			ID INT IDENTITY(1,1),
			ProductModelID INT
		)
	
	INSERT INTO Production.ProductModel
		(
			Name,
			CatalogDescription,
			Instructions
		)
	OUTPUT INSERTED.ProductModelID
		INTO @ProductModelIDTable (ProductModelID)
	SELECT 
		INSERTED.ProductModelName,
		INSERTED.CatalogDescription,
		INSERTED.Instructions
	FROM INSERTED

	DECLARE @CultureIDTable
	TABLE 
		(
			ID INT IDENTITY(1,1),
			CultureID NCHAR(6)
		)

	INSERT INTO Production.Culture
		(
			CultureID,
			Name
		)
	OUTPUT INSERTED.CultureID
		INTO @CultureIDTable (CultureID)
	SELECT
		INSERTED.CultureID,
		INSERTED.CultureName
	FROM INSERTED

	DECLARE @ProductDescriptionIDTable
	TABLE
		(
			ID INT IDENTITY(1,1),
			ProductDescriptionID INT
		)

	INSERT INTO Production.ProductDescription
		(
			Description
		)
	OUTPUT INSERTED.ProductDescriptionID
		INTO @ProductDescriptionIDTable (ProductDescriptionID)
	SELECT	
		INSERTED.Description
	FROM INSERTED

	INSERT INTO Production.ProductModelProductDescriptionCulture
		(
			ProductModelID,
			ProductDescriptionID,
			CultureID
		)
	SELECT 
		ModelID.ProductModelID,
		DescriptionID.ProductDescriptionID,
		CultureID.CultureID
	FROM @ProductModelIDTable AS ModelID
		JOIN @CultureIDTable AS CultureID
		ON ModelID.ID = CultureID.ID
		JOIN @ProductDescriptionIDTable AS DescriptionID
		ON ModelID.ID = DescriptionID.ID
GO

CREATE TRIGGER Instead_of_Update
	ON Production.ProductModelProductDescriptionCultureView
	INSTEAD OF UPDATE
AS
	UPDATE Production.ProductModel
	SET
		Name = (
			SELECT ProductModelName
			FROM INSERTED
			WHERE Production.ProductModel.ProductModelID = INSERTED.ProductModelID
		),
		CatalogDescription = (
			SELECT CatalogDescription
			FROM INSERTED
			WHERE Production.ProductModel.ProductModelID = INSERTED.ProductModelID
		),
		Instructions = (
			SELECT Instructions
			FROM INSERTED
			WHERE Production.ProductModel.ProductModelID = INSERTED.ProductModelID
		)
	WHERE Production.ProductModel.ProductModelID IN
		(
			SELECT
				ProductModelID
			FROM INSERTED
		)

	UPDATE Production.Culture
	SET
		CultureID = (
			SELECT CultureID
			FROM INSERTED
			WHERE Production.Culture.CultureID = INSERTED.CultureID
		),
		Name = (
			SELECT CultureName
			FROM INSERTED
			WHERE Production.Culture.CultureID = INSERTED.CultureID
		)
	WHERE Production.Culture.CultureID IN
		(
			SELECT
				CultureID
			FROM INSERTED
		)

	UPDATE Production.ProductDescription
	SET
		Description = (
			SELECT Description
			FROM INSERTED
			WHERE Production.ProductDescription.ProductDescriptionID = INSERTED.ProductDescriptionID
		)
	WHERE Production.ProductDescription.ProductDescriptionID IN
		(
			SELECT
				ProductDescriptionID
			FROM INSERTED
		)
GO

CREATE TRIGGER Instead_of_Delete
	ON Production.ProductModelProductDescriptionCultureView
	INSTEAD OF DELETE
AS
	IF 
		(
			NOT EXISTS
				(
					SELECT ProductModelID
					FROM Production.ProductModelProductDescriptionCulture AS UnionTable
					WHERE UnionTable.ProductModelID IN (SELECT ProductModelID FROM DELETED)
				) AND
			NOT EXISTS
				(
					SELECT CultureID
					FROM Production.ProductModelProductDescriptionCulture AS UnionTable
					WHERE UnionTable.CultureID IN (SELECT CultureID FROM DELETED)
				) AND
			NOT EXISTS
				(
					SELECT ProductDescriptionID
					FROM ProductModelProductDescriptionCulture AS UnionTable
					WHERE UnionTable.ProductDescriptionID IN (SELECT ProductDescriptionID FROM DELETED)
				)
		)
	BEGIN
		DELETE FROM Production.ProductModel
		WHERE ProductModelID IN 
			(
				SELECT ProductModelID 
				FROM DELETED
			)

		DELETE FROM Production.Culture
		WHERE CultureID IN 
			(
				SELECT CultureID 
				FROM DELETED
			)

		DELETE FROM Production.ProductDescription
		WHERE ProductDescriptionID IN 
			(
				SELECT ProductDescriptionID 
				FROM DELETED
			)
	END
GO
		

/*
	c) Вставьте новую строку в представление, указав новые данные для ProductModel, Culture и ProductDescription. 
	   Триггер должен добавить новые строки в таблицы Production.ProductModel, 
	   Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription. 
	   Обновите вставленные строки через представление. 
	   Удалите строки.
*/
INSERT INTO Production.ProductModelProductDescriptionCultureView
	(
		CultureID,
		ProductModelName,
		CultureName,
		Description
	)
VALUES 
	(
		'TESTID',
		'TEST PRODUCT NAME',
		'TEST CULTURE NAME',
		'DESCRIPTION'
	),
	(
		'TID',
		'TEST 2',
		'TEST 2',
		'TEST 2'
	);
GO

UPDATE Production.ProductModelProductDescriptionCultureView
SET 
	Production.ProductModelProductDescriptionCultureView.Description = 'NEW MODEL Description'
WHERE
	Production.ProductModelProductDescriptionCultureView.ProductModelName = 'TEST PRODUCT NAME' OR
	Production.ProductModelProductDescriptionCultureView.ProductModelName = 'TEST 2';
GO

DELETE FROM Production.ProductModelProductDescriptionCulture
WHERE CultureID = 'TESTID' OR CultureID = 'TID'

DELETE FROM Production.ProductModelProductDescriptionCultureView
WHERE Description = 'NEW MODEL Description';
GO

/*
	Для проверки содержимого таблиц
*/
SELECT 
	* 
FROM Production.ProductModelProductDescriptionCulture AS UnionTable
	JOIN Production.ProductModel AS Model
	ON UnionTable.ProductModelID = Model.ProductModelID
	JOIN Production.Culture AS Culture
	ON UnionTable.CultureID = Culture.CultureID
	JOIN Production.ProductDescription AS Description
	ON UnionTable.ProductDescriptionID = Description.ProductDescriptionID;
GO