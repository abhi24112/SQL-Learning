-- Active: 1772057030865@@127.0.0.1@5432@salesdb
/*PERFORMANCE OPTIMIZATION IN SQL*/
---------------------------------------------------------------------------------------------------------------------------------
/*1. INDEX IN SQL*/
-- Indexes in SQL are special data structures that improve query performance by allowing faster access to rows in a table. 
-- Note : connect to the "MyDatabase"
--1.  Using PostgresSQL (creates a non-clustered index by default)
SELECT
    *
FROM
    sales.customers;

-- in psql we need to use the schema name as the db name.
-- non-clustered index creation
CREATE INDEX idx_customerid ON sales.customers (customerid);

-- clustered index creation are creating the index
CLUSTER sales.customers USING idx_customerid;

CREATE INDEX idx_customer_firstname ON sales.customers (firstname);

CLUSTER sales.customers USING idx_customer_firstname;

-- 2. Using SQL Server
SELECT
    * INTO Sales.DBCustomer
FROM
    sales.customers;

SELECT
    *
FROM
    sales.DBCustomer;

-- if uses the "create index" it will create an non-clustered index by default
CREATE INDEX id_defaultIN_customer ON sales.DBCustomer (customerid);

CREATE CLUSTERED INDEX id_clustered_customer ON sales.DBCustomer (customerid);

-- mssql doesn't allow us to create more then 1 clustered index hence this will give an error.
-- CREATE CLUSTERED INDEX id_test_duplicateIN_firstname ON sales.dbcustomer(firstname);
-- 3. MySQL Indexes
CREATE INDEX idx_using_mysql_customer ON salesdb.customers (customerid);

------------------------------------------------------------------------------------------------------------

/*COMPOSITE INDEXES*/
-- An index built on more than one column.
-- 1. USING POSTGRE SQL
CREATE INDEX idx_composite_countryandscore ON sales.customers (country, score);

-- PostgreSql efficiently supports (always choose the left(first table) table of the index)
SELECT
    *
FROM
    sales.customers
WHERE
    country = 'USA';

SELECT
    *
FROM
    sales.customers
WHERE
    country = 'USA'
    AND score > 500;

-- PostgreSql dont supports (means indexing with not apply)
SELECT
    *
FROM
    sales.customers
WHERE
    score > 500;

SELECT
    *
FROM
    sales.customers;

-- 2. USING MYSQL 
-- All the syntax are same in postgresql and mysql

-- 3. USING SQL SERVER
CREATE NONCLUSTERED INDEX idx_customer_country_score
ON sales.customers(country, score);
-- Sql Server efficiently supports (always choose the left(first table) table of the index)
SELECT
    *
FROM
    sales.customers
WHERE
    country = 'USA';

SELECT
    *
FROM
    sales.customers
WHERE
    country = 'USA'
    AND score > 500;

-- Sql Server dont supports (means indexing with not apply)
SELECT
    *
FROM
    sales.customers
WHERE
    score > 500;

-----------------------------------------------------------------------------------------------------------------------

/*ColumnStore and RowStore in SQL*/
-- Mysql and postgresql are both "rowStored" by default, to introduce the columnstore we need extensions or special softwares
-- Using SQL Server
-- SQL server supposts both columnstore and rowstore but we can only create the columnstore in "Non clustered indexes"
select * from sales.customers;

-- Creating columnstore in clustered index
-- It will give error
create CLUSTERED COLUMNSTORE INDEX "clustered_columnstore" on sales.DBcustomer(customerid);
-- Creating columnstore in non-clustered index
create NONCLUSTERED COLUMNSTORE INDEX "non_clustered_columnstore" on sales.DBcustomer(customerid);