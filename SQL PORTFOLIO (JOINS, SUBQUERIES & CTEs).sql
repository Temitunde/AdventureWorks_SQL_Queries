--JOIN
--Inner Join (Joining SalesPerson and SalesOrderHeader)
SELECT p.FirstName, p.LastName, soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM Sales.SalesPerson sp
INNER JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
INNER JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID;

--Left Join (Joining Customer and SalesOrderHeader)
SELECT c.CustomerID, p.FirstName, p.LastName, soh.SalesOrderID
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
INNER JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;

--Right Join (Joining SalesTerritory and SalesPerson)
SELECT st.Name AS TerritoryName, p.FirstName, p.LastName
FROM Sales.SalesTerritory st
RIGHT JOIN Sales.SalesPerson sp ON st.TerritoryID = sp.TerritoryID
LEFT JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID;

-- Cross Join (joining Product and ProductCategory)
SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product p
CROSS JOIN Production.ProductCategory pc;

--Join with Aggregate (Total Sales Amount by Territory)-- to retrieve the total sales amount for each sales territory
SELECT st.Name AS TerritoryName, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name
ORDER BY TotalSales DESC;

--SUBQUERIES
-- To retrieve products with price list above the average for their respective subcategories.-
SELECT p.Name, p.ListPrice, p.ProductSubcategoryID
FROM Production.Product p
WHERE p.ListPrice > (
    SELECT AVG(ListPrice)
    FROM Production.Product
    WHERE ProductSubcategoryID = p.ProductSubcategoryID
);

-- To retrieve the Top 5 Highest Paid Employees Based on the Most Recent Salary
SELECT BusinessEntityID, Rate
FROM HumanResources.EmployeePayHistory e
WHERE Rate IN (
    SELECT TOP 5 Rate
    FROM HumanResources.EmployeePayHistory
    ORDER BY Rate DESC
);

--To retrieve products whose total sales are greater than the average sales for all products.
SELECT ProductID, SUM(LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > (
    SELECT AVG(TotalSales)
    FROM (
        SELECT ProductID, SUM(LineTotal) AS TotalSales
        FROM Sales.SalesOrderDetail
        GROUP BY ProductID
    ) AS ProductSales
);

--To retrieve employees who have worked in more than one department.
 SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE (SELECT COUNT(DISTINCT DepartmentID)
       FROM HumanResources.EmployeeDepartmentHistory edh
       WHERE edh.BusinessEntityID = e.BusinessEntityID) > 1;

--To identify products that have never appeared in any order.
SELECT ProductID, Name
FROM Production.Product p
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail sod
    WHERE sod.ProductID = p.ProductID
);

--CTE
--To calculate total sales for each product and returns the top 10 products.
WITH ProductSales AS (
    SELECT p.ProductID, p.Name, SUM(sod.LineTotal) AS TotalSales
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY p.ProductID, p.Name
)
SELECT TOP 10 ProductID, Name, TotalSales
FROM ProductSales
ORDER BY TotalSales DESC;

--To calculate the average sales in each sales territory.
WITH TerritorySales AS (
    SELECT st.Name AS TerritoryName, SUM(soh.SubTotal) AS TotalSales
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    GROUP BY st.Name
)
SELECT TerritoryName, AVG(TotalSales) AS AverageSales
FROM TerritorySales
GROUP BY TerritoryName;

--To retrieve customers who have placed more than one order.
WITH CustomerOrders AS (
    SELECT CustomerID, COUNT(SalesOrderID) AS OrderCount
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT CustomerID, OrderCount
FROM CustomerOrders
WHERE OrderCount > 1;

--To retrieve products not sold in the last year
WITH RecentSales AS (
    SELECT DISTINCT ProductID
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate >= DATEADD(YEAR, -1, GETDATE())
)
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN RecentSales rs ON p.ProductID = rs.ProductID
WHERE rs.ProductID IS NULL;

--To retrieve the total order amount for each customer and returns those whose total exceeds $10,000.
WITH CustomerOrderTotals AS (
    SELECT soh.CustomerID, SUM(soh.TotalDue) AS TotalOrderAmount
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
)
SELECT c.CustomerID, p.FirstName, p.LastName, TotalOrderAmount
FROM CustomerOrderTotals cot
JOIN Sales.Customer c ON cot.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE TotalOrderAmount > 10000;











