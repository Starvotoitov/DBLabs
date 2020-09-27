USE AdventureWorks2012;
GO

/*
	a) Вывести на экран неповторяющийся список должностей в каждом отделе, отсортированный по названию отдела. 
	   Посчитайте количество сотрудников, работающих в каждом отделе.
*/
SELECT
	HumanResources.Department.Name as DepartmentName,
	HumanResources.Employee.JobTitle,
	COUNT(*) AS EmpCount
FROM HumanResources.Department
	JOIN HumanResources.EmployeeDepartmentHistory
	ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID
	JOIN HumanResources.Employee
	ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
WHERE HumanResources.EmployeeDepartmentHistory.EndDate IS NULL
GROUP BY HumanResources.Department.Name,
		 HumanResources.Employee.JobTitle
ORDER BY DepartmentName;
GO

/*
	b) Вывести на экран сотрудников, которые работают в ночную смену.
*/
SELECT 
	HumanResources.Employee.BusinessEntityID,
	HumanResources.Employee.JobTitle,
	HumanResources.Shift.Name,
	HumanResources.Shift.StartTime,
	HumanResources.Shift.EndTime
FROM HumanResources.Employee
	JOIN HumanResources.EmployeeDepartmentHistory
	ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeeDepartmentHistory.BusinessEntityID
	JOIN HumanResources.Shift
	ON HumanResources.EmployeeDepartmentHistory.ShiftID = HumanResources.Shift.ShiftID
WHERE HumanResources.EmployeeDepartmentHistory.EndDate IS NULL
	AND HumanResources.Shift.Name = 'Night';
GO

/*
	c) Вывести на экран почасовые ставки сотрудников. 
	   Добавить столбец с информацией о предыдущей почасовой ставке для каждого сотрудника. 
	   Добавить еще один столбец с указанием разницы между 
	   текущей ставкой и предыдущей ставкой для каждого сотрудника.
*/
SELECT 
	HumanResources.Employee.BusinessEntityID,
	HumanResources.Employee.JobTitle,
	HumanResources.EmployeePayHistory.Rate,
	LAG(HumanResources.EmployeePayHistory.Rate, 1, 0) 
		OVER (
			PARTITION BY HumanResources.Employee.BusinessEntityID
			ORDER BY HumanResources.EmployeePayHistory.Rate
		) AS PrevRate,
	HumanResources.EmployeePayHistory.Rate - 
		LAG(HumanResources.EmployeePayHistory.Rate, 1, 0) 
		OVER (
			PARTITION BY HumanResources.Employee.BusinessEntityID
			ORDER BY HumanResources.EmployeePayHistory.Rate
		) AS Increased
FROM HumanResources.Employee
	JOIN HumanResources.EmployeePayHistory
	ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID;
GO


