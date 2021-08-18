--*************************************************************************--
-- Title: Assignment06
-- Author: Steven Michalove
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 20201-08-16,StevenMichalove,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_StevenMichalove')
	 Begin 
	  Alter Database [Assignment06DB_StevenMichalove] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_StevenMichalove;
	 End
	Create Database Assignment06DB_StevenMichalove;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_StevenMichalove;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

--Select * From [dbo].[vCategories]
-- Select * From [dbo].[vProducts]
-- Select * From [dbo].[vInventories]
--Select * From [dbo].[vEmployees]

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
 --1) You can use any name you like for you views, but be descriptive and consistent
 --2) You can use your working code from assignment 5 for much of this assignment
 --3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go



create View vCategories with schemabinding 
	as 
		select	
			Categories.CategoryID ,
			Categories.CategoryName
		from dbo.Categories;
go
-- Test it
select * from vCategories

go 
create view vProducts  with schemabinding
	as
		select
			Products.ProductID ,
			Products.ProductName,
			products.CategoryID,
			Products.UnitPrice
		from dbo.Products;
go
-- Test it
Select * from vProducts



Go
create view dbo.vEmployees with schemabinding
as
	Select
		EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
		from dbo.Employees;
go
-- Test it
select * from vEmployees
Go
create view dbo.vInventories with schemabinding
as
	Select 
		InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		[Count]
	from dbo.Inventories;
	Go

-- Test it
Select * from vInventories



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Deny public selects


Deny Select On Employees to Public;
Deny Select On Products to Public;
Deny Select on Categories to Public;
Deny Select on Inventories to Public;
go

-- allow public use to all views

Grant Select on [dbo].[vInventories]  TO public;
Grant Select on  [dbo].[vEmployees] to public;
Grant Select on  [dbo].[vCategories] to public;
Grant Select on [dbo].[vProducts] to public;

go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


-- Join both table tables using CategorID
Go

Go 
Create View [vProductsByCategories] 
as 
	
	select top 10000 Categories.CategoryName , Products.ProductName, UnitPrice from Categories
		inner join Products on Categories.CategoryID=Products.CategoryID 
	order by CategoryName, ProductName;
Go
--- Test it

Select * from [vProductsByCategories] 
 Where CategoryName = 'Beverage' and UnitPrice =  10.00

-- 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

 -- and UnitPrice =  10.00
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Show the tables
Select * from Products
Select * from Inventories;
Go


create view [vInventoriesByProductsByDates] as
-- Join tables by Inventory on  ProductID and Producs, then join Employee with EmployeeID from Inventory and Employee tables
Select top 1000 
	P.ProductName, 
	I.InventoryDate, 
	I.Count,  
	Concat( E.EmployeeFirstName ,' ', E.EmployeeLastName) as Employee  
from Products as P

Inner Join Inventories as I on P.ProductID=I.ProductID 
Inner Join Employees as E on i.EmployeeID=e.EmployeeID
Order by   P.ProductName, I.InventoryDate, I.Count, I.EmployeeID;
Go
-- test itt
Select * from [vInventoriesByProductsByDates]
go
--
-- Test it 
-- THE EXAMPLE DOES NOT MATCH THE QUESTION

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!


Select * from Inventories
Select * from Employees

Go
Create View [vInventoriesByEmployeesByDates] as
-- Join Emplyee with Inventory using EmployeeID
Select top 1000  i.InventoryDate, 
				Concat(e.EmployeeFirstName ,' ',e.EmployeeLastname) as Employee 
from Inventories as i
Inner Join Employees as e on i.EmployeeID=e.EmployeeID
group by i.InventoryDate, i.EmployeeID,e.EmployeeFirstName ,e.EmployeeLastname
Order by InventoryDate;
Go
-- Test It
Select * from [vInventoriesByEmployeesByDates]

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
Go
Create View [vInventoriesByProductsByCategories] as

Select top 1000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count 
-- join Products to Categories using CategoryID and then Joine that to Inventoriess with ProductID
from Categories as C
	Inner Join Products as P on C.CategoryID=P.CategoryID 
	Inner Join Inventories as I on P.ProductID=I.ProductID 
Order by  C.CategoryName, P.ProductName, I.InventoryDate, I.Count;
go
-- Test it
Select * from [vInventoriesByProductsByCategories]


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
Go
Create view [vInventoriesByProductsByEmployees] as
-- join Products to Categories using CategoryID and then Joine that to Inventoriess with ProductID
-- Then Join Emplyee using Employee ID
Select  Top 1000 C.CategoryName, 
	P.ProductName, 
	I.InventoryDate, 
	I.Count,  
	Concat( E.EmployeeFirstName ,' ', E.EmployeeLastName) as Employee  
from Categories as C
Inner Join Products as P on C.CategoryID=P.CategoryID 
Inner Join Inventories as I on P.ProductID=I.ProductID 
Inner Join Employees as E on i.EmployeeID=e.EmployeeID
Order by   I.InventoryDate, C.CategoryName, P.ProductName,I.EmployeeID
Go
-- test it
Select * from [vInventoriesByProductsByEmployees]

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


Go
Create view [vInventoriesForChaiAndChangByEmployees] as
-- join Products to Categories using CategoryID and then Joine that to Inventoriess with ProductID
-- Then Join Emplyee using Employee ID
Select  Top 1000 C.CategoryName, 
	P.ProductName, 
	I.InventoryDate, 
	I.Count,  
	Concat( E.EmployeeFirstName ,' ', E.EmployeeLastName) as Employee  
from Categories as C
Inner Join Products as P on C.CategoryID=P.CategoryID 
Inner Join Inventories as I on P.ProductID=I.ProductID 
Inner Join Employees as E on i.EmployeeID=e.EmployeeID
-- Limit by Chai and Chang
Where ProductName like 'Chai' or ProductName like 'Chang'
Order by   I.InventoryDate, C.CategoryName, P.ProductName,I.EmployeeID

Go
-- test it
Select * from [vInventoriesForChaiAndChangByEmployees];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Go 
Create view vEmployeesByManager as
-- Select Top 1000  * from Employees order by ManagerID
-- Place all employees in alias e
-- Place all managers in alias m
-- Join m on e by employeeID to lookup names 
SELECT  top 1000
 	concat(e.EmployeeFirstName , ' ',e.EmployeeLastName) as [Employee Name],
	concat(m.EmployeeFirstName , ' ',m.EmployeeLastName) as [Manager Name]
	FROM Employees as e
	INNER JOIN Employees as m ON m.EmployeeID = e.ManagerID
where e.EmployeeID<>m.ManagerID -- Eliminate people that report to themselves
ORDER BY
    m.EmployeeFirstName , m.EmployeeLastName;
Go
-- test it

Select * from vEmployeesByManager;
-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

go
Create view vInventoriesByProductsByCategoriesByEmployees as
	-- Join Categories with Products using CategoryID
	-- Join Products with Invtory using ProductID
	-- Join Employees with itself to find Manager name
	Select  
		P.CategoryID,
		C.CategoryName,
		P.ProductID,
		P.ProductName, 
		P.UnitPrice,
		I.InventoryID,
		I.InventoryDate, 
		I.Count,  
		E.EmployeeFirstName,
		Concat(E.EmployeeFirstName ,' ', E.EmployeeLastName) as Employee,
		concat(M.EmployeeFirstName , ' ',M.EmployeeLastName) as [Manager Name]
		from vProducts as P 
	Inner Join vCategories as C on C.CategoryID=P.CategoryID
	Inner Join vInventories as I on P.ProductID=I.ProductID 
	Inner Join vEmployees as E on I.EmployeeID=E.EmployeeID
	INNER JOIN vEmployees as M ON M.EmployeeID = E.ManagerID;

Go

-- test it
select * from [vInventoriesByProductsByCategoriesByEmployees]


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/