SELECT
    *
FROM
    information_schema.TABLES;

/*1. Subqueries in SQL*/
-- A subquery (also called a nested query or inner query) is a SQL query placed inside another query (the outer query).
-- It is enclosed in parentheses.
-- The subquery executes first, and its result is passed to the outer query.
-- Commonly used in SELECT, WHERE, and FROM clauses.
SELECT
    customerid,
    firstname,
    score
FROM
    salesdb.customers
WHERE
    score > (
        SELECT
            AVG(score)
        FROM
            salesdb.customers
    );

-- a. scalar subquery
SELECT
    score
FROM
    salesdb.customers
WHERE
    customerid = (
        SELECT
            customerid
        FROM
            salesdb.customers
        WHERE
            firstname = "Jossef"
            AND lastname = "Goldberg"
    );

-- b. row subquery
SELECT
    firstname,
    lastname
FROM
    salesdb.customers
WHERE
    customerid IN (
        SELECT
            customerid
        FROM
            salesdb.customers
        WHERE
            customerid > 3
    );

-- c. table subquery
SELECT
    orderid,
    avg_sales
FROM
    (
        SELECT
            orderid,
            AVG(sales) avg_sales
        FROM
            salesdb.orders
        GROUP BY
            orderid
    ) t
WHERE
    avg_sales > 30;

/*subquery in from clause*/
-- Ques: find the product that have a price higher then the average price of all products.
SELECT
    *
FROM
    (
        SELECT
            *,
            AVG(price) OVER () AllAvgPrice
        FROM
            salesdb.products
        GROUP BY
            productid
    ) t
WHERE
    price > AllAvgPrice;

-- Ques rank the customer based on there total amount of sales
SELECT
    *,
    RANK() OVER (
        ORDER BY
            TotalSales DESC
    ) R
FROM
    (
        SELECT
            customerid,
            SUM(sales) AS TotalSales
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ) t;

/* subquery in select clause */
-- Ques show the product id, name, price and total order without the use of window function.
SELECT
    productid,
    product,
    price,
    (
        SELECT
            COUNT(*)
        FROM
            salesdb.orders
    ) TotalOrders
FROM
    salesdb.products;

/*3. Subquery in JOINS*/
--- Ques show all customer details and find the total order of each customer
SELECT
    c.*,
    o.TotalOrders
FROM
    salesdb.customers c
    LEFT JOIN (
        SELECT
            customerid,
            COUNT(orderid) AS TotalOrders
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ) o ON c.customerid = o.customerid;

/*4. Subquery in Where clause*/
-- Ques : show the customerid and firstname and score of the customer who's score is greater the average of all customers.
SELECT
    customerid,
    firstname,
    score
FROM
    salesdb.customers
WHERE
    score > (
        SELECT
            AVG(score)
        FROM
            salesdb.customers
    );

/*Where clause with (logical Operators)*/
-- in, not in, exists, not exists, any , all
/*a. IN and NOT IN*/
SELECT
    orderid,
    customerid,
    sales
FROM
    salesdb.orders
WHERE
    customerid IN (
        SELECT
            customerid
        FROM
            salesdb.customers
        WHERE
            country = "Germany"
    );

SELECT
    orderid,
    customerid,
    sales
FROM
    salesdb.orders
WHERE
    customerid NOT IN(
        SELECT
            customerid
        FROM
            salesdb.customers
        WHERE
            country = "Germany"
    );

/*2. Exists and NOT Exists*/
-- return all customer data if any customer have made any orders.
SELECT
    customerid,
    firstname
FROM
    salesdb.customers
WHERE
    EXISTS (
        SELECT
            customerid
        FROM
            salesdb.orders
    );

-- just to show the use of "not exists"
SELECT
    customerid,
    firstname
FROM
    salesdb.customers
WHERE
    NOT EXISTS (
        SELECT
            customerid
        FROM
            salesdb.orders
        WHERE
            customerid = 5
    );

/*3. Any and All Operators*/
-- 1. ANY OPERATOR
-- checks if value matches any value within a list.
-- Ques: find female employees who's salaries are greater than the salaries of any male
SELECT
    *
FROM
    salesdb.employees
WHERE
    gender = "F"
    AND salary > ANY (
        SELECT
            salary
        FROM
            salesdb.employees
        WHERE
            gender = "M"
    );

-- 2. ALL OPERATORS
-- checks if value matches all values with in a list.
-- Ques: find female employees who's salaries are greater than the salaries of all male
SELECT
    *
FROM
    salesdb.employees
WHERE
    gender = "F"
    AND salary > ALL (
        SELECT
            salary
        FROM
            salesdb.employees
        WHERE
            gender = "M"
    );

----------------------------------------------------------------------------------------------------
/*CORRELATED SUBQUERY AND NON-CORRELATED SUBQUERY*/
/*1. Non-Correlated Subquery*/
-- Query that can run independently from the Main Query.
-- Ques: show all customer details and find the total orders of each customers
SELECT
    c.*,
    countorder.TotalOrders
FROM
    salesdb.customers c
    LEFT JOIN (
        SELECT
            o.customerid,
            COUNT(*) AS TotalOrders
        FROM
            salesdb.orders o
        GROUP BY
            o.customerid
    ) countorder ON countorder.customerid = c.customerid;

/*2. Correlated Subquery*/
-- Query that relies on the value of Main Query
-- Ques: show all customer details and find the total orders of each customers
SELECT
    *,
    (
        SELECT
            COUNT(*)
        FROM
            salesdb.orders o
        WHERE
            c.customerid = o.customerid
    ) AS TotalSales
FROM
    salesdb.customers c;

-----------------------------------------------------------------
/*CTE IN SQL*/
-- it is like a temporary table the that can be used in the main query in multiple place which we can't do in subquery as it can only be used in one place at a time.
USE salesdb;

/*Type of CTEs*/
/*1. Non-Recursive CTEs*/
-- 1. STANDALONE CTE
-- Ques find the total sales per customers.
WITH
    CTE_Total_Sales AS (
        SELECT
            customerid,
            SUM(sales) TotalSales
        FROM
            salesdb.orders
        GROUP BY
            customerid
    )
SELECT
    c.customerid,
    c.firstname,
    c.lastname,
    cte.TotalSales
FROM
    salesdb.customers c
    LEFT JOIN CTE_Total_Sales cte ON cte.customerid = c.customerid;

-- 2. MULTIPLE STANDALONE CTE
-- find the total sales per customer and find the last order date for each customer.
WITH
    CTE_Total_Sale AS (
        SELECT
            customerid,
            SUM(sales) AS TotalSales
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ),
    CTE_Last_OrderDate AS (
        SELECT
            customerid,
            MAX(orderdate) AS Last_order_date
        FROM
            salesdb.orders
        GROUP BY
            customerid
    )
SELECT
    c.customerid,
    c.firstname,
    c.lastname,
    ts.TotalSales,
    lo.Last_order_date
FROM
    salesdb.customers c
    LEFT JOIN CTE_Total_Sale ts ON c.customerid = ts.customerid
    LEFT JOIN CTE_Last_OrderDate lo ON c.customerid = lo.customerid;

/*3. Nested CTE*/
-- Ques: 
-- find the total sales per customer
-- find the last orderdate per customer
-- Rank customer based on total sales per customer
WITH
    CTE_Total_Sales AS (
        SELECT
            customerid,
            SUM(sales) AS total_sales
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ),
    CTE_Rank_TotalSales AS (
        SELECT
            *,
            RANK() OVER (
                ORDER BY
                    total_sales
            ) AS Customer_Ranking_By_TotalSales
        FROM
            CTE_Total_Sales
    ),
    CTE_Last_Orderdate AS (
        SELECT
            customerid,
            MAX(orderdate) AS last_orderdate
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ),
    CTE_customer_segment AS (
        SELECT
            *,
            (
                CASE
                    WHEN total_sales > 100 THEN "Loyal"
                    WHEN total_sales > 60 THEN "Regular"
                    ELSE "Not Loyal"
                END
            ) AS Segment
        FROM
            CTE_Total_Sales
    )
SELECT
    c.customerid AS cust_id,
    c.firstname,
    c.lastname,
    o.last_orderdate AS LastOrder,
    r.total_sales AS TotalSales,
    r.Customer_Ranking_By_TotalSales AS rankingBySales,
    cs.Segment AS Customer_Segmenatation
FROM
    salesdb.customers c
    LEFT JOIN CTE_Last_Orderdate AS o ON o.customerid = c.customerid
    LEFT JOIN CTE_Rank_TotalSales AS r ON r.customerid = c.customerid
    LEFT JOIN CTE_customer_segment AS cs ON cs.customerid = c.customerid
WHERE
    r.Customer_Ranking_By_TotalSales IS NOT NULL
ORDER BY
    rankingBySales;

/*2. Recursive CTEs*/
-- self referencing query that repeatedly processes data until a specific condition is met.
-- generate a sequence of number from 1 to 20
WITH RECURSIVE
    Series (Mynumber) AS (
        SELECT
            1 AS Mynumber
        UNION ALL
        SELECT
            Mynumber + 1
        FROM
            Series
        WHERE
            Mynumber < 20
    )
SELECT
    *
FROM
    Series;

-- Return the fibonacci series
WITH RECURSIVE
    CTE_Fibonacci (n, a, b) AS (
        SELECT
            1 AS n,
            0 AS a,
            1 AS b
        UNION ALL
        SELECT
            n + 1,
            b,
            a + b
        FROM
            CTE_Fibonacci
        WHERE
            n < 5
    )
SELECT
    a AS Fibonacci_Series
FROM
    CTE_Fibonacci;

-- Factorial Series
WITH RECURSIVE
    CTE_Factorial (n, Factorial) AS (
        SELECT
            1 AS n,
            1 AS Factorial
        UNION ALL
        SELECT
            n + 1,
            Factorial * (n + 1)
        FROM
            CTE_Factorial
        WHERE
            n < 5
    )
SELECT
    *
FROM
    CTE_Factorial;

-- Ques: show the employee hierarchy by displaying each employees level within the organization
WITH RECURSIVE
    CTE_Emp_Hierarchy AS (
        SELECT
            employeeid,
            firstname,
            managerid,
            1 AS LEVEL
        FROM
            salesdb.employees
        WHERE
            managerid IS NULL
        UNION ALL
        SELECT
            e.employeeid,
            e.firstname,
            e.managerid,
            LEVEL + 1
        from salesdb.employees e
        inner join CTE_Emp_Hierarchy ceh
        on e.managerid = ceh.employeeid
    )
SELECT
    *
FROM
    CTE_Emp_Hierarchy;