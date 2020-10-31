USE AdventureWorks2012;
GO

/*
	a) Создайте таблицу Production.ProductModelHst, 
	   которая будет хранить информацию об изменениях в таблице Production.ProductModel.
	   Обязательные поля, которые должны присутствовать в таблице: 
		   ID - первичный ключ IDENTITY(1,1); 
		   Action - совершенное действие (insert, update или delete); 
		   ModifiedDate - дата и время, когда была совершена операция; 
		   SourceID - первичный ключ исходной таблицы; 
		   UserName - имя пользователя, совершившего операцию. 
	   Создайте другие поля, если считаете их нужными.
*/
CREATE TABLE Production.ProductModelHst
	(
		ID INT IDENTITY(1, 1) PRIMARY KEY,
		Action VARCHAR(6) CHECK (ACTION IN ('INSERT', 'UPDATE', 'DELETE')),
		ModifiedDate DATETIME,
		SourceID INT,
		UserName VARCHAR(20)
	);

/*
	b) Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.ProductModel. 
	   Триггер должен заполнять таблицу Production.ProductModelHst с указанием типа операции в поле Action 
	   в зависимости от оператора, вызвавшего триггер.
*/
CREATE TRIGGER ProductModel_Insert
	ON Production.ProductModel
	AFTER INSERT
AS
	INSERT INTO Production.ProductModelHst
	SELECT
		'INSERT',
		GETDATE(),
		INSERTED.ProductModelID,
		CURRENT_USER
	FROM INSERTED;
GO

CREATE TRIGGER ProductModel_Update
	ON Production.ProductModel
	AFTER UPDATE
AS
	INSERT INTO Production.ProductModelHst
	SELECT
		'UPDATE',
		GETDATE(),
		DELETED.ProductModelID,
		CURRENT_USER
	FROM DELETED;
GO

CREATE TRIGGER ProductModel_Delete
	ON Production.ProductModel
	AFTER DELETE
AS
	INSERT INTO Production.ProductModelHst
	SELECT
		'DELETE',
		GETDATE(),
		DELETED.ProductModelID,
		CURRENT_USER
	FROM DELETED;
GO

/*
	c) Создайте представление VIEW, отображающее все поля таблицы Production.ProductModel.
*/
CREATE VIEW Production.ProductModelView
AS
	SELECT 
		*
	FROM Production.ProductModel;
GO

/*
	d) Вставьте новую строку в Production.ProductModel через представление. 
	   Обновите вставленную строку. 
	   Удалите вставленную строку. 
	   Убедитесь, что все три операции отображены в Production.ProductModelHst.
*/
INSERT INTO Production.ProductModelView 
	(
		Name
	)
VALUES
	(
		'Test product'
	);

UPDATE Production.ProductModelView
SET Name = 'Updated name'
WHERE Name = 'Test product';

DELETE FROM Production.ProductModelView
WHERE Name = 'Updated name';

SELECT *
FROM Production.ProductModelHst;