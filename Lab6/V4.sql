USE AdventureWorks2012;
GO

/*
	a) Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
	   отображающую данные о количестве работников, 
	   нанятых в каждый отдел (HumanResources.Department) за определённый год (HumanResources.EmployeeDepartmentHistory.StartDate). 
	   Список лет передайте в процедуру через входной параметр.
	   Таким образом, вызов процедуры будет выглядеть следующим образом:
	   EXECUTE dbo.EmpCountByDep ‘[2003],[2004],[2005]’
*/
CREATE PROCEDURE dbo.EmpCountByDep
	@yearsList VARCHAR(50)
AS
BEGIN
	DECLARE @query VARCHAR(MAX)
	SET @query = 
	'	SELECT
			Name,
	'  
			+ @yearsList +	
	'	FROM
			(
				SELECT
					Department.Name,
					YEAR(History.StartDate) AS Year
				FROM HumanResources.Department AS Department
					JOIN HumanResources.EmployeeDepartmentHistory AS History
					ON Department.DepartmentID = History.DepartmentID
			) AS SourceTable
		PIVOT
			(
				COUNT(Year)
				FOR Year 
				IN ( 
	'
					+ @yearsList +
	'			)
			) AS PivotTable;
	'
	EXEC(@query)
END;
GO

/*
	Вызов хранимой процедуры
*/
EXECUTE dbo.EmpCountByDep '[2003],[2004],[2005]';
GO
