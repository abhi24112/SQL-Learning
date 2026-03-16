/*Golden Rule*/
-- Always check the execution plan to confirm performance improvement when optimizing your query.

use SalesDB;

-- =====================================================
/* A. FETCHING DATA*/
-- =====================================================
-- 1. Select Only Waht You Need
-- Bad Practice
SELECT * FROM sales.Customers;

-- Good Practice
SELECT customerid, firstname, lastname FROM sales.Customers;

-- 2. Avoid Unnecessay DISTINCE & ORDER BY
-- Bad Practice
SELECT DISTINCT firstname FROM sales.Customers order by firstname;

-- Good Practice
SELECT firstname FROM sales.Customers;

-- 3.  For exploration, limit the number of rows using TOP to avoid fetching unnecessary data
-- Bad Practice (if lot of data)
SELECT customerid, firstname, lastname FROM sales.Customers;

-- Good Practice
SELECT top 3 customerid, firstname, lastname FROM sales.Customers;

-- =====================================================
/* B. FILTERING DATA*/
-- =====================================================

-- 1. Create "non-clustered" indexes on columns frequently used in the WHERE to speed up queries
SELECT * FROM sales.Orders WHERE Orderstatus = 'Delivered';

CREATE NONCLUSTERED index idx_OrderDelivered on Sales.Orders(Orderstatus);

-- 2.  Avoid functions e.g., UPPER(), YEAR() to columns in the WHERE , as this prevents indexes from being used

-- a. Bad Practice (Prevents the index usage)
SELECT * FROM sales.Orders WHERE LOWER(Orderstatus) = 'delivered';

-- a. Good Practice
SELECT * FROM sales.Orders WHERE Orderstatus = 'Delivered';

-- b. Bad Practice
SELECT * FROM Sales.Customers WHERE SUBSTRING(FirstName, 1, 1) = 'A';
-- b. Good Practice
SELECT * FROM Sales.Customers WHERE FirstName LIKE 'A%';

-- c. Bad Practice
SELECT *
FROM Sales.Orders WHERE YEAR(OrderDate) = 2025;

-- c. Good Practice
SELECT *
FROM Sales.Orders 
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31';

-- 3. Avoid starting string searches with a wildcard (%example), as this disables index usage
-- Bad Practice
SELECT * FROM Sales.Customers WHERE LastName LIKE '%Gold%';

-- Good Practice
SELECT * FROM Sales.Customers WHERE LastName LIKE 'Gold%';

-- 4.  Use IN instead of multiple OR 

-- Bad Practice
SELECT *
FROM Sales.Orders
WHERE Customerid = 1 or customerid = 2 or customerid = 3;

-- Good Practice
SELECT *
FROM Sales.Orders
WHERE CustomerID IN (1,2,3);

-- =====================================================
/* C. JOINING DATA*/
-- =====================================================
-- 1. Understand The Speed of Joins & Use INNER JOIN when possible
-- Best Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c 
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- Slightly Slower Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c 
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;
SELECT c.FirstName, o.OrderID FROM Sales.Customers c 
RIGHT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- Worst Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c 
OUTER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;


-- 2.  use explicit (ANSI-style) joins (INNER JOIN, LEFT JOIN, etc.) instead of older implicit join 
-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Orders o, Sales.Customers c
WHERE o.CustomerID = c.CustomerID;

-- Good Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Orders o
INNER JOIN Sales.Customers c
on o.CustomerID = c.CustomerID;

-- 3. Make Sure to Index the Column  used in the Where Clause
SELECT o.OrderID, c.FirstName
FROM Sales.Orders o
INNER JOIN Sales.Customers c
on o.CustomerID = c.CustomerID;
-- here we need to have a index column 'CustomerID' for both the tables.
CREATE NONCLUSTERED INDEX idx_Order_CustID on Sales.Orders(CustomerID);
CREATE NONCLUSTERED INDEX idx_customer_CustID on Sales.customers(CustomerID);

-- 4. "Filter before joining large tables" to reduce the size of the dataset being joined

-- a. Filter After Join (Where) (Works well for small data)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.OrderID
WHERE o.Orderstatus = 'Delivered';

-- b. Filter During Join (ON) (Works well for small data)
SELECT c.FirstName, o.OrderID, o.Orderstatus
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.OrderID
and o.Orderstatus = 'Delivered';

-- c. Filter Before Join (Subquery) (Works well for Large data)
SELECT OrderID, Customerid FROM Sales.Orders WHERE Orderstatus = 'Delivered';
SELECT c.FirstName, o.OrderID
FROM Sales.Customers c
INNER JOIN (SELECT OrderID, Customerid FROM Sales.Orders WHERE Orderstatus = 'Delivered') o
ON c.CustomerID = o.OrderID;

-- 5. Aggregate Before Joining (Big Table)

-- a. Grouping and Joining (Best for Small - Medium Table)
SELECT c.CustomerID, c.FirstName, COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName;

-- b. Pre-aggregated Subquery (Best For Big Tables)
SELECT c.CustomerID, c.FirstName,o.OrderCount
FROM Sales.Customers c
INNER JOIN (
    SELECT CustomerID, count(OrderID) AS OrderCount
    FROM Sales.Orders
    GROUP BY CustomerID
    ) as o
ON c.CustomerID = o.CustomerID;


-- c. Correlated Subquery (Worst Performace Due to Aggregation for each row)
SELECT
    c.CustomerID,
    c.FirstName,
    (SELECT count(o.OrderID)
    FROM Sales.Orders o WHERE 
    o.CustomerID = c.Customerid) as OrderCount
FROM Sales.Customers c

-- 6. Use Union Instead of OR in Joins

-- "Replace OR conditions in join logic with UNION" where possible to improve query performance

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
OR c.CustomerID = o.SalesPersonID;-- Here 'OR' eats the performance

-- Good Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
UNION
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.SalesPersonID;

-- 7. Check for Nested Loops and Use SQL HINTS (Execution Plan)

SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID;

-- Good Practice for Having Big Table and Small Tables
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
OPTION (HASH JOIN);

--  Use UNION ALL instead of UNION if duplicates are acceptable

-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive;

-- Good Practice
SELECT CustomerID FROM Sales.Orders
UNION ALL
SELECT CustomerID FROM Sales.OrdersArchive;

-- =====================================================
/* D. AGGREGATING DATA*/
-- =====================================================
-- 1. Use ColumnStore Index for Aggregations on Large Table
SELECT CustomerID, COUNT(OrderID) as OrderCount
FROM Sales.ORders
GROUP BY CustomerID;

CREATE CLUSTERED COLUMNSTORE INDEX idx_Orders_ColumnStore ON Sales.Orders;

-- 2. Pre - Aggregate Data and store it in new Table for Reporting

SELECT MONTH(OrderDate) OrderYear, SUM(Sales) as TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

SELECT * FROM Sales.SalesSummary;


-- =====================================================
/* E. SUBQUERIES*/
-- =====================================================

-- 1. Understand when to use JOIN, EXISTS, or IN. Avoid IN with large lists 
-- JOIN (Best Practice: If the performance equal to EXISTS)
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
WHERE c.Country = 'USA';

-- EXISTS (Best for Large Tables)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
WHERE EXISTS (
    SELECT 1 FROM Sales.Customers c 
    WHERE c.CustomerID = o.CustomerID
    and c.Country = 'USA'
)

-- IN (Bad Practice)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
WHERE o.OrderID IN (
    SELECT OrderID from Sales.Customers WHERE Country = 'USA' 
);

-- 2. Avoid Reduandant Logic in Your Query

-- Bad Practice
SELECT EmployeeID, FirstName , 'Above Avg' Status
FROM Sales.Employees
WHERE Salary > (SELECT avg(Salary) FROM Sales.Employees)
UNION ALL
SELECT EmployeeID, FirstName , 'Below Avg' Status
FROM Sales.Employees
WHERE Salary < (SELECT avg(Salary) FROM Sales.Employees);

-- Good Practice
SELECT EmployeeID, FirstName,
CASE 
    WHEN Salary > AVG(Salary) OVER() THEN 'Above Avg'  
    WHEN Salary < AVG(Salary) OVER() THEN 'Below Avg'  
    ELSE 'Average' 
END as Status
FROM Sales.Employees

-- =====================================================
/* F. DDL TIPS*/
-- =====================================================
-- 1. Use AS Little As you can the Varchar and TEXT Data type while Creating the Table.
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(MAX),
    LastName VARCHAR(50), --  LastName TEXT ❌
    Score VARCHAR(255),
    EmployeeID INT,
    CONSTRAINT FK_CustomerInfo_EmployeeID Foreign Key (EmployeeID) REFERENCES Sales.Employees(EmployeeID)
);

-- 2. Avoid defining excessive lengths in your data types (e.g., VARCHAR(MAX))
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(50), -- VARCHAR(MAX) ❌
    LastName VARCHAR(50),
    Score INT, -- Score VARCHAR(255) ❌
    EmployeeID INT,
    CONSTRAINT FK_CustomerInfo_EmployeeID Foreign Key (EmployeeID) REFERENCES Sales.Employees(EmployeeID)
);

-- 3. Use NOT NULL were it can apply
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Score INT NOT NULL,
    EmployeeID INT,
    CONSTRAINT FK_CustomerInfo_EmployeeID Foreign Key (EmployeeID) REFERENCES Sales.Employees(EmployeeID)
);

-- 4. Ensure all tables have a clustered primary key 

CREATE TABLE CustomersInfo (
    CustomerID INT PRIMARY KEY CLUSTERED,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Score INT NOT NULL,
    EmployeeID INT,
    CONSTRAINT FK_CustomerInfo_EmployeeID Foreign Key (EmployeeID) REFERENCES Sales.Employees(EmployeeID)
);

-- 5.  "Add non-clustered indexes to foreign keys" that are frequently queried to speed up lookups

CREATE NONCLUSTERED INDEX idx_foreign_EmployeeID ON CustomersInfo(EmployeeID);

-- =====================================================
/* G. INDEXING Perfomance TIPS*/
-- =====================================================

-- 1. Avoid Over Indexing

-- 2. drop unused indexes (Moniter Index Usage)
-- Shows how often indexes are used
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.indexes AS i
JOIN sys.dm_db_index_usage_stats AS s
    ON i.object_id = s.object_id
    AND i.index_id = s.index_id
ORDER BY s.user_seeks DESC;

-- 3.  Update table statistics weekly to ensure the query optimizer 

-- 4.  Reorganize and rebuild fragmented indexes weekly

-- 5. For large tables (e.g., fact tables), partition the data and then apply a columnstore index for best performance results