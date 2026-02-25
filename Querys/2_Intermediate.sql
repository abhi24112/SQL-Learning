-- Active: 1768674083043@@127.0.0.1@3306
/*Comparision Operators*/
-- Retrieve all customer from Germany
SELECT
    *
FROM
    customers
WHERE
    country = "Germany";

-- customer score greater then 500
SELECT
    *
FROM
    customers
WHERE
    score >= 500;

SELECT
    *
FROM
    customers
WHERE
    score < 500;

SELECT
    *
FROM
    customers
WHERE
    score > 500;

-------------------------------------------------------------------
-- LOGICAL OPERATORS
-- customer who are from USA andhave score greater than 500
SELECT
    *
FROM
    customers
WHERE
    country = "USA"
    AND score > 500;

-- customer who are either from USA or score greater than 500
SELECT
    *
FROM
    customers
WHERE
    country = "USA"
    OR score > 500;

-- String Pattern (start of end of string)
-- find the name of the customer who's name starts from 'r';
SELECT
    *
FROM
    customers
WHERE
    first_name LIKE "%r%";

-- name where 'o' is at thrid position
SELECT
    *
FROM
    customers
WHERE
    first_name LIKE "__o%";

-------------------------------------------------------------------
-- CASE STATEMENT IN SQL
--CASE is a conditional expression (clause) used to add if-else logic inside SQL queries
SELECT
    firstname,
    lastname,
    salary,
    CASE
        WHEN salary > 70000 THEN "High Pay"
        ELSE "Low Pay"
    END AS Salary_Status
FROM
    salesdb.employees;

-- Ques : Create repost showing "total sales" for each of the following categories: 
-- High: (sales over 50)
-- Medium: (sales 20-50)
-- Low: (sales 20 or less)
-- sort the categories from higest sales to lowest.
SELECT
    orderid,
    sales,
    CASE
        WHEN sales >= 50 THEN "High"
        WHEN sales > 20 THEN "Medium"
        ELSE "Low"
    END AS SalesCategory
FROM
    salesdb.orders
ORDER BY
    sales DESC;

-- final answer.
SELECT
    SalesCategory,
    SUM(sales) AS total_amount
FROM
    (
        SELECT
            sales,
            CASE
                WHEN sales > 50 THEN "High"
                WHEN sales > 20 THEN "Medium"
                ELSE "Low"
            END AS SalesCategory
        FROM
            salesdb.orders
    ) t
GROUP BY
    SalesCategory
ORDER BY
    total_amount DESC;

--  Data Mapping
-- Ques : Retrieve employee details with gender dispalyed as full text
SELECT
    employeeid,
    firstname,
    gender,
    CASE
        WHEN gender = "M" THEN "Male"
        WHEN gender = "F" THEN "Female"
        ELSE "Not Available"
    END AS full_Gender
FROM
    salesdb.employees;

-- Ques Retrive customers details with abbreviated country code
SELECT
    customerid,
    firstname,
    country,
    CASE
        WHEN country IS NOT NULL THEN LEFT(country, 2)
        ELSE "Not Available"
    END AS country_code
FROM
    salesdb.customers;

-- other way
SELECT
    customerid,
    firstname,
    country,
    CASE
        WHEN country = "Germany" THEN "DE"
        WHEN country = "USA" THEN "US"
        ELSE "Not Available"
    END AS country_code
FROM
    salesdb.customers;

-- Condition in CASE
-- If we have the multiple country and we are writing something like this:
SELECT
    customerid,
    firstname,
    country,
    CASE
        WHEN country = "Germany" THEN "DE"
        WHEN country = "USA" THEN "US"
        WHEN country = "India" THEN "IN"
        WHEN country = "United Kingdom" THEN "UK"
        WHEN country = "Italy" THEN "IT"
        ELSE "Not Available"
    END AS country_code
FROM
    salesdb.customers;

-- here the country is used multiple time and same operator "=" is used
-- we can also write like this:
SELECT
    customerid,
    firstname,
    country,
    CASE country
        WHEN "Germany" THEN "DE"
        WHEN "USA" THEN "US"
        WHEN "India" THEN "IN"
        WHEN "United Kingdom" THEN "UK"
        WHEN "Italy" THEN "IT"
        ELSE "Not Available"
    END AS country_code
FROM
    salesdb.customers;

-- Handling NULL with CASE Statements
-- Ques find the average scores of customers and treat NULL as 0 
-- Additionally provide details such as CustomerID, and Firstname
SELECT
    customerid,
    firstname,
    AVG(score) OVER () AS AvgScore,
    AVG(
        CASE
            WHEN score IS NULL THEN 0
            ELSE score
        END
    ) OVER () AS AvgScoreNullHandled
FROM
    salesdb.customers;

-- Ques: Count how may times each customer has made an order with sales greater than 30?
SELECT
    customerid,
    SUM(
        CASE
            WHEN sales > 30 THEN 1
            ELSE 0
        END
    ) total_no_orders
FROM
    salesdb.orders
GROUP BY
    customerid;

-- another way
SELECT
    c.customerid,
    c.firstname,
    COUNT(*) AS no_of_orders
FROM
    salesdb.customers c
    JOIN salesdb.orders o ON c.customerid = o.customerid
WHERE
    o.sales > 30
GROUP BY
    customerid;

-------------------------------------------------------------------
-- JOINS in Sql
-- INNER JOIN IN SQL
-- retrieve all data from customer and orders as serparate results
SELECT
    *
FROM
    customers;

SELECT
    *
FROM
    orders;

SELECT
    *
FROM
    customers c
    INNER JOIN orders o ON c.id = o.customer_id;

-- get all customers along with their order, but only for customers who have placed an order.
SELECT
    c.id,
    first_name,
    o.order_id,
    o.sales
FROM
    customers c
    INNER JOIN orders o ON c.id = o.customer_id;

-- LEFT JOIN IN SQL
USE mydatabase;

--Ques: Get all customers along with their orders, including those without order.
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c
    LEFT JOIN mydatabase.orders o ON c.id = o.customer_id;

-- RIGHT JOIN IN SQL
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    customers c
    RIGHT JOIN orders o ON c.id = o.customer_id;

-- FULL JOIN IN SQL
-- get all customer and orders, even if there's no match
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c FULL
    JOIN mydatabase.orders o -- full join is not supported in mysql 
    ON c.id = o.customer_id;

-- work around
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c
    LEFT JOIN mydatabase.orders o ON c.id = o.customer_id
UNION
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c
    RIGHT JOIN mydatabase.orders o ON c.id = o.customer_id;

-------------------------------------------------------------------
-- ADVANCE JOIN IN SQL
-- LEFT ANTI JOIN
-- returns row from left that has "no match" in right.
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c
    LEFT JOIN mydatabase.orders o ON c.id = o.customer_id
WHERE
    o.customer_id IS NULL;

-- RIGHT ANTI JOIN
-- returns row from right that has no match in left
--Ques: get all orders without matching customers
SELECT
    order_id,
    customer_id,
    order_date,
    sales
FROM
    customers c
    RIGHT JOIN orders o ON c.id = o.customer_id
WHERE
    c.id IS NULL;

-- FULL ANIT JOIN
SELECT
    *
FROM
    mydatabase.customers c
    LEFT JOIN mydatabase.orders o ON o.customer_id = c.id
WHERE
    o.customer_id IS NULL
UNION
SELECT
    *
FROM
    mydatabase.customers c
    RIGHT JOIN mydatabase.orders o ON o.customer_id = c.id
WHERE
    c.id IS NULL;

-- INNER JOIN IN SQL
/*Get all customers along with their order, but only for 
customers who have placed an order*/
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    customers c
    INNER JOIN orders o ON c.id = o.customer_id;

/*Get all customers along with their order, but only for 
customers who have placed an order "WIHTOUT USING INNER JOIN"*/
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM
    mydatabase.customers c
    LEFT JOIN mydatabase.orders o ON c.id = o.customer_id
WHERE
    o.order_id IS NOT NULL;

-- CROSS JOIN IN SQL
SELECT
    *
FROM
    customers c
    CROSS JOIN orders o;

-------------------------------------------------------------------
-- MULTI TABLE JOIN (Advanced join types)
/*Using salesdb, retrieve a list of all orders, along with the related customers , product, and employee details. 
for each order display: 
- orderid
- customer name
- product name
- sales amount 
- product price
- salesperson's name*/
USE salesdb;

SHOW TABLES;

SELECT
    *
FROM
    salesdb.products;

SELECT
    *
FROM
    salesdb.orders;

SELECT
    *
FROM
    salesdb.customers;

SELECT
    *
FROM
    salesdb.orders_archive;

SELECT
    *
FROM
    salesdb.employees;

SELECT
    o.orderid AS "OrderID",
    c.firstname AS "CustomerFirstName",
    c.lastname AS "CustomerLastName",
    p.product AS "ProductName",
    o.sales AS "Sales",
    p.price AS "Price",
    e.employeeid AS "EmployeeID",
    e.firstname AS "EmployeeFirstName",
    e.lastname AS "EmployeeLastName"
FROM
    orders o
    LEFT JOIN salesdb.customers c ON o.customerid = c.customerid
    LEFT JOIN salesdb.products p ON o.productid = p.productid
    LEFT JOIN salesdb.employees e ON o.salespersonid = e.employeeid;

-- Ques find the manager names of the employees 
SELECT
    e.employeeid,
    CONCAT_WS(
        " ",
        COALESCE(e.firstname, ""),
        COALESCE(e.lastname, "")
    ) AS SalesName,
    e.managerid,
    CONCAT_WS(
        " ",
        COALESCE(e1.firstname, "CEO"),
        COALESCE(e1.lastname, "")
    ) AS ManagerName,
    e.gender AS SalesGender,
    e.birthdate AS SalesBirtDate,
    e.department AS SalesDepartment,
    e.salary AS SaleSalary
FROM
    salesdb.employees e
    LEFT JOIN salesdb.employees e1 ON e.managerid = e1.employeeid

-------------------------------------------------------------------
-- SET METHODS IN SQL (Order by is allowed at end only)
/*Union, Unionall, Except, Intersection*/
-- set rules
/*
1. set operators can be used in any clause.
2. ORDER BY  is allowed only once - at the end of the query.
3. each query must have the same number of columns.
4. Columns data types must be compatible across queries.
5. the result set takes column name and alias from the first query 
table.
 */
-- Query follow all rules
SELECT
    firstname,
    lastname
FROM
    salesdb.customers
UNION
SELECT
    firstname,
    lastname
FROM
    salesdb.employees;

-- Query that doesn't follow the data compatiliblity rule.
SELECT
    customerid
FROM
    salesdb.customers
UNION
SELECT
    birthdate
FROM
    salesdb.employees;

-- equal no of column is needed.
-- here customerid and birthdate have different datatypes but union still works how?
/*In your case, INT and DATE don’t match directly.

MySQL resolves this by promoting both to a string type (VARCHAR) internally*/
-- But for mssql this will give an error that data is not compatible.
-------------------------------------------------------------------
-- 1. UNION IN SQL (returns all the distinct rows from both tables)
/*Ques: Combine the data from employees  and customers into one table*/
SELECT
    customerid,
    firstname,
    lastname
FROM
    salesdb.customers
UNION
SELECT
    employeeid,
    firstname,
    lastname
FROM
    salesdb.employees;

-------------------------------------------------------------------
-- UNION ALL IN SQL
/*
- return all rows from both table with duplicates
- Union All is faster then the Union, because it doesn't need to 
remove the duplicates
- Use Union All to find duplicates and quality issues.
 */
SELECT
    customerid,
    firstname,
    lastname
FROM
    salesdb.customers
UNION ALL
SELECT
    employeeid,
    firstname,
    lastname
FROM
    salesdb.employees;

-- union has 8 rows of data
-- union all has 10 rows of data.
-------------------------------------------------------------------
-- EXCEPT Clause (Minus a - b)
/*
1. return unique rows from 1'st table that are not in 2nd table.
2. The order of the table matters.
 */
SELECT
    firstname,
    lastname
FROM
    salesdb.customers EXCEPT
SELECT
    firstname,
    lastname
FROM
    salesdb.employees;

/*
Output:
firstname    lastname
Jossef	     Goldberg 
Mark	     Schwarz
Anna	     Adams -------------(Anna has duplicate data in firsttable and Except givex uniquedata.)
 */
-- different approach (using left join)
SELECT
    c.firstname,
    c.lastname
FROM
    salesdb.customers c
    LEFT JOIN salesdb.employees e ON c.firstname = e.firstname
WHERE
    e.firstname IS NULL;

-------------------------------------------------------------------
-- INTERSECT IN SQL
/*
1. returns common rows data from both tables.
 */
SELECT
    firstname,
    lastname
FROM
    salesdb.customers INTERSECT
SELECT
    firstname,
    lastname
FROM
    salesdb.employees;

/* Ques: Orders are stored in separated tables 
(Orders and OrderArchive)
combine all orders into one report without duplicates*/
SELECT
    *
FROM
    salesdb.orders
UNION
SELECT
    *
FROM
    salesdb.orders_archive;

-- Best Practice : never use asterisk(*)
SELECT
    "Orders" AS Sourcetable,
    orderid,
    productid,
    customerid,
    salespersonid,
    orderdate,
    shipdate,
    orderstatus,
    shipaddress,
    billaddress,
    quantity,
    sales,
    creationtime
FROM
    salesdb.orders
UNION
SELECT
    "OrdersArchive" AS Sourcetable,
    orderid,
    productid,
    customerid,
    salespersonid,
    orderdate,
    shipdate,
    orderstatus,
    shipaddress,
    billaddress,
    quantity,
    sales,
    creationtime
FROM
    salesdb.orders_archive;

-------------------------------------------------------------------
-- ROW LEVEL FUNCTION IN SQL
-- 1. STRING FUNCTION
/*a. Concat function*/
-- Ques: show a list of customers first names together with their country in one column
SELECT
    CONCAT(first_name, "-", country) AS "name and country"
FROM
    mydatabase.customers;

-- more efficient code
SELECT
    CONCAT_WS("-", first_name, country) AS "name and country"
FROM
    mydatabase.customers;

/* b. Upper and lower function */
-- Ques: Transform the customer's firstname  to lowercase
SELECT
    CONCAT_WS("-", first_name, country) AS "name and country",
    LOWER(first_name) AS first_name,
    UPPER(first_name) AS first_name
FROM
    mydatabase.customers;

/*c. Trim function*/
-- Ques: find customers whose first name contains leading or trailing spaces
-- detect white spaces
SELECT
    first_name,
    TRIM(first_name)
FROM
    mydatabase.customers
WHERE
    first_name != TRIM(first_name);

SELECT
    first_name,
    LENGTH(first_name)
FROM
    mydatabase.customers;

--removing white space
SELECT
    first_name,
    LENGTH(first_name) AS whitespace_first_name,
    TRIM(first_name) AS Trimed_first_name,
    LENGTH(TRIM(first_name))
FROM
    mydatabase.customers;

/*d. Replace Function*/
-- Ques: remove dashes (-) from a phone numbers
SELECT
    '123-456-789' AS phone,
REPLACE
    ('123-456-789', '-', '') AS clened_phone_no;

SELECT
    'report.txt' AS txt,
REPLACE
    ('report.txt', 'txt', 'csv') AS csv;

/*e. Left function*/
SELECT
    'report is here' AS "text value",
    LEFT('report is here', 6) AS "left 5 char";

/*f. Right function*/
SELECT
    'report is here' AS "text value",
    RIGHT('report is here', 4) AS "right 4 char";

/*g. Substring(value, start, length)*/
-- Ques: after the second charaters extract 2 characters
SELECT
    "wake up to reality" AS text_value,
    SUBSTRING("wake up to reality", 3, 2) AS sub_string;

-- Ques: retrieve a list of customer's first names after removing the first character
SELECT
    first_name,
    SUBSTRING(TRIM(first_name), 2, LENGTH(TRIM(first_name))) AS sub_name
FROM
    mydatabase.customers;

SELECT
    first_name,
REPLACE
    (first_name, LEFT(first_name, 1), "")
FROM
    mydatabase.customers;

-------------------------------------------------------------------
-- NUMBER FUNCTION IN SQL
-- 1. Round in sql
SELECT
    3.516,
    ROUND(3.516, 2) AS rounded_value;

SELECT
    3.516,
    ROUND(3.516, 1) AS rounded_value;

SELECT
    3.516,
    ROUND(3.516, 0) AS rounded_value;

-- 2. Absolute in sql
SELECT
    -10,
    ABS(-10),
    ABS(10);

-------------------------------------------------------------------
-- DATE AND TIME FUNCTION IN SQL
SELECT
    orderid,
    orderdate,
    shipdate,
    creationtime
FROM
    salesdb.orders;

/*a. NOW() function*/
SELECT
    orderid,
    creationtime,
    '2025-08-02' HardCoded,
    NOW() Today
FROM
    salesdb.orders;

/*b. Date() function*/
SELECT
    DATE(NOW()) AS DATE;

/*c. Year() function*/
SELECT
    YEAR(NOW()) AS year_no;

/*d. Month() function*/
SELECT
    MONTH(NOW()) AS year_no;

/*e. day() function*/
SELECT
    DAY(NOW()) AS year_no;

/*f. Extract() function*/
SELECT
    orderid,
    creationtime,
    EXTRACT(
        YEAR
        FROM
            creationtime
    ) AS YEAR,
    EXTRACT(
        MONTH
        FROM
            creationtime
    ) AS MONTH,
    EXTRACT(
        DAY
        FROM
            creationtime
    ) AS DAY,
    EXTRACT(
        HOUR
        FROM
            creationtime
    ) AS HOUR,
    EXTRACT(
        MINUTE
        FROM
            creationtime
    ) AS MINUTE,
    EXTRACT(
        SECOND
        FROM
            creationtime
    ) AS SECOND
FROM
    salesdb.orders;

/*g. DAYNAME() function*/
SELECT
    DAYNAME(NOW()) AS day_name;

/*h. MONTHNAME() function*/
SELECT
    MONTHNAME(NOW()) AS month_name;

/*i. weekday() function*/
SELECT
    WEEKDAY(NOW()) AS week_no;

/*j. Date_Format() in sql */
-- DATE_FORMAT() function is used to format the date in mysql.
SELECT
    Orderid,
    creationtime,
    DATE_FORMAT(creationtime, "%Y-%m-%d %H:%i:%s") AS second_truc,
    DATE_FORMAT(creationtime, "%Y-%m-%d %H:%i:00") AS minute_truc,
    DATE_FORMAT(creationtime, "%Y-%m-%d %H:00:00") AS Hour_truc,
    DATE_FORMAT(creationtime, "%Y-%m-%d 00:00:00") AS Day_truc,
    DATE_FORMAT(creationtime, "%Y-%m-01 00:00:00") AS Month_truc,
    DATE_FORMAT(creationtime, "%Y-01-01 00:00:00") AS Year_truc
FROM
    salesdb.orders
LIMIT
    5;

/*k. Last_Day() function - End of Month*/
SELECT
    DATE(creationtime),
    LAST_DAY(creationtime) AS endOfMonth,
    (LAST_DAY(creationtime) - DATE(creationtime)) AS Difference
FROM
    salesdb.orders;

/*l. DateADD() function */
SELECT
    DATE('2002-11-24') AS dob,
    DATE_ADD(DATE('2002-11-24'), INTERVAL 23 YEAR) AS date_after_23_year,
    DATE_SUB(DATE('2002-11-24'), INTERVAL 23 YEAR) AS date_before_23_year;

-- will throw a syntax error ❌ because INTERVAL is not a standalone expression.
USE salesdb;

/*m. DATEDIFF() Fuction*/
-- finds the diffence of days between dates.
SELECT
    DATE(NOW()) AS date1,
    DATE('2002-11-24') AS date2,
    DATEDIFF(DATE(NOW()), DATE('2002-11-24')) AS Day_diff,
    YEAR(NOW()) - YEAR('2002-11-24') AS Year_diff,
    MONTH('2002-11-24') - MONTH(NOW()) AS month_diff;

-- start of the month - using date_format()
SELECT
    DATE(creationtime),
    DATE_FORMAT(creationtime, "%Y-%m-01") AS startOfMonth
FROM
    salesdb.orders;

-- Ques: How many orders were placed each year, month, quarter?
SELECT
    YEAR(orderdate) AS YEAR,
    COUNT(*) AS NoOfOrder
FROM
    salesdb.orders
GROUP BY
    YEAR(orderdate);

SELECT
    MONTHNAME(orderdate) AS YEAR,
    COUNT(*) AS NoOfOrder
FROM
    salesdb.orders
GROUP BY
    MONTHNAME(orderdate);

SELECT
    QUARTER(orderdate) AS YEAR,
    COUNT(*) AS NoOfOrder
FROM
    salesdb.orders
GROUP BY
    QUARTER(orderdate);

-- Ques: Show all orders that were placed during the month of February.
SELECT
    *
FROM
    salesdb.orders
WHERE
    MONTH(orderdate) = 2;

SELECT
    *
FROM
    salesdb.orders;

-------------------------------------------------------------------
-- FORMATING AND CASTING IN SQL
/*1. FORMAT() Function in Sql */
-- format a number with ccommas and decimal places in sql
/*syntax
FORMAT(value, decimal_places, [, local](optional))*/
SELECT
    FORMAT(123123.345, 2) AS formated_number;

SELECT
    FORMAT(123123.345, 0) AS formated_number;

/*2. DATE_FORMAT() Function in sql*/
-- use to format dates in mysql
SELECT
    orderdate,
    DATE_FORMAT(orderdate, '%d-%m-%Y-%W'),
    DATE_FORMAT(orderdate, '%D-%M-%Y-%w'),
    DATE_FORMAT(orderdate, '%d-%b-%Y-%a'),
    DATE_FORMAT(orderdate, '%M-%Y'),
    DATE_FORMAT(orderdate, '%D-%b'),
    DATE_FORMAT(orderdate, '%M')
FROM
    salesdb.orders;

SELECT
    creationtime,
    CONCAT_WS(
        " ",
        "Day",
        DATE_FORMAT(creationtime, "%a %b %Y"),
        CONCAT("Q", QUARTER(creationtime)),
        DATE_FORMAT(creationtime, "%H:%i:%s %p")
    )
FROM
    salesdb.orders;

/*
%W - weekname(full)
%a - weekname(short)
%M - Monthname(full)
%b - monthname(short)
%i - minutes
%s - seconds
%p - PM/AM
 */
-------------------------------------------------------------------
-- HANDLING NULL VALUES IN SQL 
--(ISNULL, IFNULL, COALESCE, NULLIF, IS NULL, IS NOT NULL)
/*1. ISNULL in sql
syntax: 
ISNULL(expr)
 */
SELECT
    billaddress,
    ISNULL(billaddress) AS Is_null
FROM
    salesdb.orders;

-- 0 and 1
/*2. IFNULL in sql
syntax: 
IFNULL(expr, replacement_value)
 */
SELECT
    billaddress,
    shipaddress,
    IFNULL(billaddress, shipaddress) AS combine_address
FROM
    salesdb.orders;

-- ISNULL() can't take more then 2 arguments.
SELECT
    billaddress,
    shipaddress,
    IFNULL(billaddress, IFNULL(shipaddress, "UNKNOWN")) AS Final_address
FROM
    salesdb.orders;

/*3. COALESCE() in sql
syntax: 
COALESCE(expr, replacement_value)
 */
SELECT
    billaddress,
    shipaddress,
    COALESCE(billaddress, "unknown") AS handled_billaddress,
    COALESCE(billaddress, shipaddress) AS bill_or_shipaddress,
    COALESCE(billaddress, shipaddress, "unknown") AS bill_ship_unknow_address
FROM
    salesdb.orders;

SELECT
    *
FROM
    salesdb.orders;

-------------------------------------------------------------------
-- USECASE OF COALESCE AND ISNULL
/*1. Handling NULL Before Data Aggregation*/
-- Ques; Find the average scores of the customers?
SELECT
    customerid,
    score,
    AVG(score) OVER () AvgScore,
    COALESCE(score, 0) AS score2,
    AVG(COALESCE(score, 0)) OVER () AvgScore2
FROM
    salesdb.customers;

-- Here, we can see the score2 has low average then the score, it is due to the "0" values (350 + 900 + 750 + 500)/6 not divide by 4
SHOW TABLES;

/*2. Handling NULL before doing mathematical operations*/
/*
1 + 5 = 6
"a" + "b" = "ab"

NULL + 5 = NULL
NULL + "b" = NULL
 */
-- Ques: Display the full name of customers in a single field by merging their firstname and lastnames, and add 10 bounus points to each customer's score?
SELECT
    CONCAT_WS("-", firstname, lastname) AS fullName,
    score,
    score + 10 AS Newscores,
    COALESCE(score, 0) AS score2,
    COALESCE(score, 0) + 10 AS NewScores2
FROM
    salesdb.customers;

/*3. Handling NULL before JOINing Tables */
SELECT
    c.firstname,
    c.lastname,
    e.salary
FROM
    salesdb.customers c
    INNER JOIN 
    salesdb.employees e ON c.firstname = e.firstname
    AND c.lastname = e.lastname;

-- SQL is not able to compare the NULL values,
-- Hence, it is not giving the "Mary   (NULL)  75000" result
-- Now, handling the NULL error
SELECT
    c.firstname,
    c.lastname,
    e.salary
FROM
    salesdb.customers c
    INNER JOIN salesdb.employees e ON c.firstname = e.firstname
    AND COALESCE(c.lastname, "") = COALESCE(e.lastname, "");

/*4. Handling NULL before sorting the data*/
-- Ques: Sort the customers from lowest to highest scores
-- with nulls appearing last
SELECT
    firstname,
    score
FROM
    salesdb.customers
ORDER BY
    CASE
        WHEN score IS NULL THEN 1
        ELSE 0
    END,
    score ASC;

/*5. Handling Zero Division Error using NULL value.*/
-- NULLIF() in Sql
-- returns NULL if both expression in NULLIF(expr1, expr2) are equal.
SELECT
    salespersonid,
    orderstatus,
    NULLIF(orderstatus, "Delivered") AS NewStauts
FROM
    salesdb.orders;

SELECT
    salespersonid,
    orderstatus,
    NULLIF(shipaddress, billaddress) AS NewStauts
FROM
    salesdb.orders;

-- zero division
SELECT
    orderid,
    sales,
    Quantity,
    sales / NULLIF(Quantity, 0) AS price_per_unit
FROM
    salesdb.orders;

-------------------------------------------------------------------
-- NULL vs EMPTY vs SPACE
WITH
    Orders AS (
        SELECT
            1 Id,
            "A" Category
        UNION
        SELECT
            2,
            NULL
        UNION
        SELECT
            3,
            ""
        UNION
        SELECT
            4,
            " "
    )
SELECT
    Category,
    LENGTH(Category) AS LENGTH
FROM
    Orders
    -- Cleaning the data from nulls, spaces, empty
WITH
    Orders AS (
        SELECT
            1 Id,
            "A" Category
        UNION
        SELECT
            2,
            NULL
        UNION
        SELECT
            3,
            ""
        UNION
        SELECT
            4,
            " "
    )
SELECT
    Category,
    TRIM(Category) Policy1,
    NULLIF(TRIM(Category), "") AS Policy2,
    COALESCE(NULLIF(TRIM(Category), ""), "unknown") Policy3
FROM
    Orders
