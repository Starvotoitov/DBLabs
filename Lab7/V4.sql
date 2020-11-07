USE AdventureWorks2012;
GO

/*
	a) Вывести значения полей [BusinessEntityID], [Name], [AccountNumber] 
	   из таблицы [Purchasing].[Vendor] в виде xml, сохраненного в переменную. 
	   Формат xml должен соответствовать примеру.
*/
DECLARE @xml XML

SET @xml = (
SELECT
	Vendor.BusinessEntityID AS ID,
	Vendor.Name,
	Vendor.AccountNumber
FROM Purchasing.Vendor AS Vendor
FOR XML PATH ('Vendor'), ROOT('Vendors'));

/*
	b) Создать хранимую процедуру, возвращающую таблицу, заполненную из xml переменной представленного вида. 
	   Вызвать эту процедуру для заполненной на первом шаге переменной.
*/
EXECUTE dbo.parseVendorXML @xml;
GO

/*
	Запрос для создания хранимой процедуры.
*/
CREATE PROCEDURE dbo.parseVendorXML
	@xml XML
AS
	SELECT
		Tbl.Col.value('ID[1]', 'INT') AS ID,
		Tbl.Col.value('Name[1]', 'NVARCHAR(50)') AS Name,
		Tbl.Col.value('AccountNumber[1]', 'NVARCHAR(15)') AS AccountNumber
	FROM @xml.nodes('/Vendors/Vendor') Tbl(Col);
GO
