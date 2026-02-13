-- AGGEGATION FUNCTION
-- Ques: Find the total number, total sales, average sales, Highest and lowerest sales of orders
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    AVG(sales) AS avg_sales,
    MAX(sales) AS Highest_sales,
    MIN(sales) AS Lowest_sales
FROM
    mydatabase.orders
GROUP BY
    customer_id;

-----------------------------------------------------------------------
-- WINDOW FUNCTION BASICS
/*
An SQL function that computes values over a group of rows (called a window) while still returning one row per input row

It is defined using the OVER clause, which specifies the "window" of rows for the calculation.
 */
-- Ques: find the total sales across all orders
SELECT
    SUM(sales) AS total_sales
FROM
    salesdb.orders;

-- Ques: find the total sales for each products
SELECT
    productid,
    SUM(sales) AS total_sales
FROM
    salesdb.orders
GROUP BY
    productid;

-- Ques: find the total sales for each products, additionally provide details such as orderid and order date.
SELECT
    orderid,
    orderdate,
    productid,
    SUM(sales) AS total_sales
FROM
    salesdb.orders
GROUP BY
    productid,
    orderid,
    orderdate;

-- now we are hiting the limits of group by function because we are not able to see the total sales of each productid.
-- Now, window function come into action;
SELECT
    orderid,
    orderdate,
    productid,
    SUM(sales) OVER (
        PARTITION BY
            productid
    ) AS total_sales
FROM
    salesdb.orders
ORDER BY
    productid;

/*QUESTION AND ANSWER USING OVER AND PARTITION BY*/
-- 1. find the total sales across all orders additionally provide details such order id and order date.
-- 2. find the total sales across for each product, additionally provide details such order id and order date.
-- 3. find the total sales for each combination of product and order status
SELECT
    orderid,
    orderdate,
    productid,
    orderstatus,
    sales,
    SUM(sales) OVER () AS TotalSales,
    SUM(sales) OVER (
        PARTITION BY
            productid
    ) AS SalesByProduct,
    SUM(sales) OVER (
        PARTITION BY
            productid,
            orderstatus
    ) AS SalesByProductsAndStatus
FROM
    salesdb.orders;

/*Order by in Over() function*/
-- use to order the window by desc/asc
/*QUESTION AND ANSWER USING ORDER BY IN OVER FUNCTION*/
-- Ques 1. Rank each order based on their sales from highest to lowest, additionally provide details such as order id, order date.
SELECT
    orderid,
    orderdate,
    sales,
    RANK() OVER (
        ORDER BY
            sales
    ) AS RankInASC
FROM
    salesdb.orders;

SELECT
    orderid,
    orderdate,
    sales,
    RANK() OVER (
        ORDER BY
            sales DESC
    ) AS RankInDESC
FROM
    salesdb.orders;

-- Ques 2. Find the total sales for each order status, only for two products 101 and 102
SELECT
    productid,
    orderid,
    orderstatus,
    SUM(sales) OVER (
        PARTITION BY
            orderstatus
    ) TotalSalesByProductid
FROM
    salesdb.orders
WHERE
    productid IN (101, 102);

-- Window function can be used together with Group By in the same query
-- Only if the same columns are used.
-- Ques: Rank the customers based on their total sales
SELECT
    customerid,
    SUM(sales) TotalSales,
    RANK() OVER (
        ORDER BY
            SUM(sales) DESC
    ) AS RankCustomer
FROM
    salesdb.orders
GROUP BY
    customerid;

----------------------------------------------------------------------------------------------
-- FRAME CLAUSE IN WINDOW FUNCITONS
/*
- Defines the subset of rows in a window function.
- It actually decides which rows participate in the calculation.
 */
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND 2 FOLLOWING
    ) AS RunningTotal,
    AVG(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND 2 FOLLOWING
    ) AS RunningAVG,
    AVG(COALESCE(sales, 0)) OVER (
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND 2 FOLLOWING
    ) AS RunningAVGNOTNULL
FROM
    salesdb.orders;

-- using UNBOUNDED FOLLOWING : last row of the data.
-- It is like reverse Running Total.
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND UNBOUNDED FOLLOWING
    ) AS UNBOUNDEDFollowing
FROM
    salesdb.orders;

-- Using N-PRECEDING 
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN 1 PRECEDING
            AND CURRENT ROW
    ) AS OnePrecedingSum
FROM
    salesdb.orders;

-- Using UNBOUNDED PRECEDING
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS UNBOUNDEDPrecedingSum
FROM
    salesdb.orders;

-- Using PRECEDING AND FOLLOWING
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN 1 PRECEDING
            AND 1 FOLLOWING
    ) AS PrecedingFollowingSum
FROM
    salesdb.orders;

-- Using UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
SELECT
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS UN_Preceding_UN_FollowingSum
FROM
    salesdb.orders;

-- example
SELECT
    orderid,
    orderdate,
    orderstatus,
    SUM(sales) OVER (
        PARTITION BY
            orderstatus
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND 2 FOLLOWING
    ) TotalSales
FROM
    salesdb.orders;

----------------------------------------------------------------------------------------------
/*AGGREGATION FUNCIONS IN MYSQL*/
-- 1. Count() agg
-- Ques: find the total number of orders for each product
SELECT
    productid,
    COUNT(orderid) AS totalOrder
FROM
    salesdb.orders
GROUP BY
    productid;

-- Count(*) -> count the number of row even if the value is cell value null.
SELECT
    productid,
    COUNT(*) OVER (
        PARTITION BY
            productid
    )
FROM
    salesdb.orders;

-- count(column) -> count on the non-null values in a column
SELECT
    productid,
    COUNT(orderid) OVER (
        PARTITION BY
            productid
    )
FROM
    salesdb.orders;

-- Ques; find the total nubmer of customers
-- find the total number of score of each customers
-- Additionally provide all customers details
SELECT
    *,
    COUNT(*) OVER () total_customers,
    COUNT(score) OVER () total_scores
FROM
    salesdb.customers;

/*Handling Duplicates Using count*/
-- Ques: Check whether table order_archieve contains any duplicate rows.
SELECT
    *
FROM
    (
        SELECT
            orderid,
            COUNT(*) OVER (
                PARTITION BY
                    orderid
            ) AS CheckPk
        FROM
            salesdb.orders_archive
    ) t
WHERE
    CheckPk > 1;

-- 2. Sum() aggregation
-- Ques: Find the total sales across all orders
-- And the total sales for each product
-- Additionally provide details such order ID, order date
SELECT
    orderid,
    orderdate,
    sales,
    productid,
    SUM(sales) OVER () TotalSales,
    SUM(sales) OVER (
        PARTITION BY
            productid
    ) TotalSalesByProduct
FROM
    salesdb.orders;

/*Comparision Use Case*/
-- Compare the current value and aggregated value of window function.
-- Ques: find the percentage contribution of each product's sales to the total sales
-- also find the Percentage contribution of each category of products.
SELECT
    productid,
    sales,
    SUM(sales) OVER () TotalSales,
    ROUND(sales / SUM(sales) OVER () * 100, 2) PecentageContribution,
    CONCAT_WS(
        "",
        ROUND(
            SUM(sales) OVER (
                PARTITION BY
                    productid
            ) / SUM(sales) OVER () * 100,
            2
        ),
        "%"
    ) PerContriProductCategory
FROM
    salesdb.orders;

-- 3. AVG() aggregation
-- Ques; Find the average sales across all order and
-- find the average for each product
-- Additionally provide  details such order id, order date.
SELECT
    productid,
    orderid,
    ROUND(AVG(sales) OVER (), 2) AverageSales,
    ROUND(
        AVG(sales) OVER (
            PARTITION BY
                productid
        ),
        2
    ) AverageSales
FROM
    salesdb.orders;

-- Ques: Find the average scores of customers
-- Additionally provide details such customer id and lastname
SELECT
    customerid,
    lastname,
    score,
    COALESCE(score, 0) AS HandleNull,
    AVG(score) OVER () AvgScore,
    AVG(COALESCE(score, 0)) OVER () AvgScore
FROM
    salesdb.customers;

-- Ques: Find all orders where sales are higher than the averge sales across all ordes.
SELECT
    orderid,
    sales,
    AverageSales
FROM
    (
        SELECT
            orderid,
            sales,
            AVG(COALESCE(sales, 0)) OVER () AS AverageSales
        FROM
            salesdb.orders
    ) t
WHERE
    sales > AverageSales;

-- MIN() and MAX() Function with Window function
-- Ques: find the highest sales for each product
-- Ques: find the lowest sales for each product
-- Additioanlly provide details such as orderid, order date.
SELECT
    orderid,
    orderdate,
    productid,
    sales,
    MAX(sales) OVER (
        PARTITION BY
            productid
    ) MaximumSales,
    MIN(sales) OVER (
        PARTITION BY
            productid
    ) MinimumSales
FROM
    salesdb.orders;

-- Ques: show the employee who have the highest salaries
SELECT
    *
FROM
    salesdb.employees
WHERE
    salary = (
        SELECT
            MAX(salary)
        FROM
            salesdb.employees
    );

SELECT
    *
FROM
    (
        SELECT
            *,
            MAX(salary) OVER () MaxSalary
        FROM
            salesdb.employees
    ) t
WHERE
    salary = MaxSalary;

-- Ques: Calcualte the deviation of each sales from both the minimum and maximum sales amounts.
SELECT
    productid,
    orderid,
    orderdate,
    sales,
    MAX(sales) OVER () HighestSales,
    MIN(sales) OVER () LowestSales,
    sales - MIN(sales) OVER () AS DeviationFromMin,
    MAX(sales) OVER () - sales AS DeviationFromMax
FROM
    salesdb.orders;

-------------------------------------------------------------------------
-- RUNNING TOTAL AND ROLLING TOTAL
/*1. Running Total(Cumulative Sum)*/
/*First Way: 
Find the cumulative Sum or Running Sum of sales by orderdate.
 */
-- Default Frame Clause : rows between unbounded preceding and current row.
SELECT
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate
    ) AS CumulativeSumWindownFn
FROM
    salesdb.orders;

SELECT
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS CumulativeSumWindownFn
FROM
    salesdb.orders;

-- Older MySQL versions don’t have window functions, so you can use user-defined variables:
SET
    @cumulativeSum := 0;

SELECT
    orderid,
    orderdate,
    sales,
    @cumulativeSum := @cumulativeSum + sales AS CumulativeSumOLD
FROM
    salesdb.orders;

/*
2. Rolling Total 
 */
SELECT
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY
            orderdate ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
    ) AS RollingTotal
FROM
    salesdb.orders;

-- Ques: Calculate the moving average of sales for each product over time
-- Ques: Calculate the moving average of sales for each product over time, including only the next order
SELECT
    orderid,
    productid,
    orderdate,
    sales,
    AVG(sales) OVER (
        PARTITION BY
            productid
        ORDER BY
            orderdate
    ) AS MovingAvgSales,
    AVG(sales) OVER (
        PARTITION BY
            productid
        ORDER BY
            orderdate ROWS BETWEEN CURRENT ROW
            AND 1 FOLLOWING
    ) RollingAvgWithNextOrder
FROM
    salesdb.orders;

-------------------------------------------------------------------------
-- RANKING WINDOW FUNCTION
/*1. Row_number()*/
-- assigns a unique sequential number to each row in the window.
-- Ques 1:  Rank the orders based on there sales from highest to lowest
SELECT
    orderid,
    sales,
    ROW_NUMBER() OVER (
        ORDER BY
            sales DESC
    ) OrderRanking
FROM
    salesdb.orders;

-- Ques 2: assign rank's to each customer by the total_amount of sales.
SELECT
    customerid,
    SUM(sales) TotalSales,
    ROW_NUMBER() OVER (
        ORDER BY
            SUM(sales) DESC
    ) RankOfCustomer
FROM
    salesdb.orders
GROUP BY
    customerid
ORDER BY
    TotalSales DESC;

/*2. Rank() function*/
-- similar to the row_number()
-- but it handles the "ties" and assign the same rank to ties.
-- BUT IT LEAVES THE GAPS IN THE RANKING.
-- Ques 1: Rank the orders based on there sales from highest to lowest but assign same rank if ties is there.
SELECT
    orderid,
    sales,
    ROW_NUMBER() OVER (
        ORDER BY
            sales DESC
    ) SalesRank_Row,
    RANK() OVER (
        ORDER BY
            sales DESC
    ) SalesRank_Rank
FROM
    salesdb.orders;

/*3. Dense_Rank()*/
-- `Dense_Rank()` is similar to the rank but there is a significant difference that make the dense rank different from  `Rank()`
-- it also gives the rank to every row but it `doesn’t skips the rank`
-- if two same value get assigned with same rank , next rank will get the one increased number.
-- Ques 1: Rank the orders based on there sales from highest to lowest but assign same rank if ties is there but also don't make gaps in the rank.
SELECT
    orderid,
    sales,
    ROW_NUMBER() OVER (
        ORDER BY
            sales DESC
    ) SalesRank_Row,
    RANK() OVER (
        ORDER BY
            sales DESC
    ) SalesRank_Rank,
    DENSE_RANK() OVER (
        ORDER BY
            sales DESC
    ) SalesRank_DenseRank
FROM
    salesdb.orders;

/*USE CASE OF ROW_NUMBER*/
-- 1. TOP-N ANALYSIS
-- Ques find the top-3 highest sales for each product
SELECT
    *
FROM
    (
        SELECT
            orderid,
            productid,
            sales,
            ROW_NUMBER() OVER (
                PARTITION BY
                    productid
                ORDER BY
                    sales DESC
            ) SalesRank
        FROM
            salesdb.orders
    ) t
WHERE
    SalesRank <= 3;

/*2. BOTTON-N ANALYSIS*/
-- Ques: Find the lowest 2 customers based on their total sales.
SELECT
    *
FROM
    (
        SELECT
            customerid,
            SUM(sales) TotalSales,
            ROW_NUMBER() OVER (
                ORDER BY
                    SUM(sales)
            ) AS TotalSales_Rank
        FROM
            salesdb.orders
        GROUP BY
            customerid
    ) t
WHERE
    TotalSales_Rank <= 2;

/*3. Generate Unique ID's*/
-- Assign Unique Id's to the rows fo the Order_archieve table
SELECT
    *,
    ROW_NUMBER() OVER (
        ORDER BY
            orderdate
    ) AS UniqueID
FROM
    salesdb.orders_archive;

/*4. Indentify Duplicates in table*/
-- Identify duplicates rows in the table "Order archieve"
-- and return a clean result without any duplicates.
SELECT
    *
FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY
                    orderid
                ORDER BY
                    creationtime
            ) duplicate_count
        FROM
            salesdb.orders_archive
    ) t
WHERE
    duplicate_count = 1;

/*4. NTILE() FUNCTION*/
-- divides the data into parts by assigning same number to each group
-- bucket Size = no. of rows/ no. of buckets = 10/2 = 5
-- 1 will come 5 time and 2 with come 5 times
SELECT
    sales,
    NTILE(2) OVER (
        ORDER BY
            sales DESC
    ) TwoBucket,
    NTILE(1) OVER (
        ORDER BY
            sales DESC
    ) OneBucket
FROM
    salesdb.orders;

-- What if the no. rows are ODD like 11
-- = 11/2 = 5
-- RULE: Larger groups come first means 1 with come 6 times.
SELECT
    sales,
    NTILE(4) OVER (
        ORDER BY
            sales DESC
    ) FourBucket,
    NTILE(2) OVER (
        ORDER BY
            sales DESC
    ) TwoBucket,
    NTILE(1) OVER (
        ORDER BY
            sales DESC
    ) OneBucket,
    NTILE(3) OVER (
        ORDER BY
            sales DESC
    ) OddBuckets -- similar example.
FROM
    salesdb.orders;

-- USECASE OF "NTILE"
-- 1. Data Analyst - (Data Segmentation)
/*
Divides a dataset into distinct subsets based on certain criteria.
 */
-- Ques: Segment all orders into 3 categories high, medium and low sales.
SELECT
    *,
    CASE
        WHEN Bucket = 3 THEN "low"
        WHEN Bucket = 2 THEN "medium"
        ELSE "high"
    END AS Category_segment
FROM
    (
        SELECT
            orderid,
            sales,
            NTILE(3) OVER (
                ORDER BY
                    sales DESC
            ) AS Bucket
        FROM
            salesdb.orders
    ) t;

-- 2. Data Engineer - (Equalizing load Processing)
-- Ques: In order to export the data divide the orders into 2 groups.
SELECT
    *,
    NTILE(2) OVER (
        ORDER BY
            orderid
    ) BUCKETS
FROM
    salesdb.orders;

/*5. CUME_DIST() Cumulative distribution Window Function*/
-- CUME_DIST() calculates the cumulative distribution of a value in a dataset. 
SELECT
    orderid,
    sales,
    CUME_DIST() OVER (
        ORDER BY
            sales
    ) AS cume_distribution
FROM
    salesdb.orders;

-- Interpretation: 70% of order have sales <= 50
SELECT
    orderid,
    sales,
    CUME_DIST() OVER (
        ORDER BY
            sales DESC
    ) AS cume_distribution
FROM
    salesdb.orders;

-- Interpretation: 30% of order have sales >= 60
-- Ques: find teh products that fall within the highest 40% of the prices
SELECT
    *
FROM
    (
        SELECT
            product,
            price,
            CUME_DIST() OVER (
                ORDER BY
                    price DESC
            ) DistRank
        FROM
            salesdb.products
    ) t
WHERE
    DistRank <= 0.4;

/*5. PERCENT_RANK()*/
-- gives the relative rank of a row compared to others, scaled between 0 and 1.Lowest value → 0.0, Highest value → 1.0.
-- PERCENT_RANK() is about relative standing in the ordered list.
-- Ques: find teh products that fall within the highest 40% of the prices
SELECT
    product,
    price,
    DistRank,
    CONCAT(DistPercentRank * 100, "%") AS DistRankPerc
FROM
    (
        SELECT
            product,
            price,
            CUME_DIST() OVER (
                ORDER BY
                    price DESC
            ) DistRank,
            PERCENT_RANK() OVER (
                ORDER BY
                    price DESC
            ) DistPercentRank
        FROM
            salesdb.products
    ) t
WHERE
    DistRank <= 0.4;

-----------------------------------------------------------------------------
/*VALUE WINDOW FUNCTIONS*/
-- Lead, Lag, First_value, Last_value
-- These are designed to pull actual values from other rows in the window rather than compute aggregates or rankings.
/*1. Lead() and Lag() functions*/
-- Lead: access next row with in the window.
-- Lag: access previous row with in the window.
-- Ques: Analyze the month-over-month(MoM) Performance by finding the percentage changes in sales between the current and previous month
SELECT
    MONTH(orderdate) month_num,
    SUM(sales)
FROM
    salesdb.orders
GROUP BY
    month_num;

SELECT
    *,
    CurrentMonthSales - PreviousMonthSales AS MoM_Change,
    CONCAT(
        ROUND(
            COALESCE(
                (CurrentMonthSales - PreviousMonthSales) / PreviousMonthSales * 100,
                0
            ),
            2
        ),
        "%"
    ) AS MoM_Perc_Change
FROM
    (
        SELECT
            MONTH(orderdate) month_num,
            SUM(sales) CurrentMonthSales,
            LAG(SUM(sales)) OVER (
                ORDER BY
                    MONTH(orderdate)
            ) PreviousMonthSales
        FROM
            salesdb.orders
        GROUP BY
            month_num
    ) t;

-- CUSTOMER RETENTION ANALYSIS
-- measure customer's behavior and loyalty to help businesses build strong relationships with customers.
-- Ques: Analyze customer loyalty by ranking customers based on the average number of days between orders.
SELECT
    customerid,
    AVG(DaysBeforeThisOrder) avg_day,
    rank() over(order BY AVG(DaysBeforeThisOrder) desc)
FROM
    (
        SELECT
            customerid,
            orderdate,
            LAG(orderdate) OVER (
                PARTITION BY
                    customerid
                ORDER BY
                    orderdate
            ) PreviousDate,
            DATEDIFF(
                orderdate,
                LAG(orderdate) OVER (
                    PARTITION BY
                        customerid
                    ORDER BY
                        orderdate
                )
            ) DaysBeforeThisOrder
        FROM
            salesdb.orders
    ) t
GROUP BY customerid
having AVG(DaysBeforeThisOrder) is not null;