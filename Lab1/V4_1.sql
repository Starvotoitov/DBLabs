/*
	a) Напишите запрос на создание новой базы данных 
	   используя инструкцию CREATE DATABASE
*/
CREATE DATABASE Vitali_Starovoitov;
GO

USE Vitali_Starovoitov;
GO

/*
	b) Создайте новую схему с помощью инструкции CREATE SCHEMA
*/
CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

/*
	c) Создайте новую таблицу в схеме sales с именем Orders, 
	   содержащей одно поле OrderNum, 
	   тип данных которого INT
*/
CREATE TABLE sales.Orders 
	(
		OrderNum INT NULL
	);
GO

/*
	d) Создайте бэкап базы данных 
	   используя инструкцию BACKUP DATABASE и 
	   сохраните его в файловой системе.
*/
BACKUP DATABASE Vitali_Starovoitov
TO DISK = 'D:\Vitali_Starovoitov.bak';
GO  

/*
	e) Удалите базу данных используя инструкцию DROP DATABASE.
*/
DROP DATABASE Vitali_Starovoitov;
GO

/*
	f) Восстановите базу данных из сохраненного бэкапа 
	   используя инструкцию RESTORE DATABASE.
*/
RESTORE DATABASE Vitali_Starovoitov
FROM DISK = 'D:\Vitali_Starovoitov.bak';
GO