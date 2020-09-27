USE AdventureWorks2012;
GO

/*
	a) Вывести на экран список отделов, принадлежащих группе `Executive General and Administration`.
*/
SELECT Name, GroupName
FROM HumanResources.Department
WHERE GroupName = 'Executive General and Administration';
GO

/*
	b) Вывести на экран максимальное количество оставшихся часов отпуска у сотрудников. 
	   Назовите столбец с результатом `MaxVacationHours`.
*/
SELECT MAX(ALL VacationHours)
	AS MaxVacationHours
FROM HumanResources.Employee;
GO

/*
	c) Вывести на экран сотрудников, название позиции которых включает слово `Engineer`.
*/
SELECT BusinessEntityID, JobTitle, Gender, BirthDate, HireDate
FROM HumanResources.Employee
WHERE CHARINDEX('Engineer', JobTitle) <> 0;
GO

