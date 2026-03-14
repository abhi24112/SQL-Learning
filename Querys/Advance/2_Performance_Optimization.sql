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
CREATE NONCLUSTERED INDEX idx_customer_country_score ON sales.customers (country, score);

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
USE SalesDB;

-- Mysql and postgresql are both "rowStored" by default, to introduce the columnstore we need extensions or special softwares
-- Using SQL Server
-- SQL server supposts both columnstore and rowstore but we can only create the columnstore in "Non clustered indexes"
SELECT
    *
FROM
    sales.customers;

-- Creating columnstore in clustered index
-- It will give error
CREATE CLUSTERED COLUMNSTORE INDEX cluster_columnstore ON sales.DBcustomer;

-- Creating columnstore in non-clustered index 
-- (creating in differnet table because in one table we can't create more than one columnstore index)
CREATE NONCLUSTERED COLUMNSTORE INDEX non_clustered_columnstore ON sales.products (productid);

/*Doing in AdventureWorks Dataset*/
USE AdventureWorksDW2022;

SELECT
    top 10 *
FROM
    FactInternetSales;

-- Heap
SELECT
    * INTO FactInternetSales_HP
FROM
    FactInternetSales;

-- RowStore (default is rowstore)
SELECT
    * INTO FactInternetSales_RS
FROM
    FactInternetSales;

CREATE CLUSTERED INDEX idx_FactInternetSales_RS_PK ON FactInternetSales_RS (SalesOrderNumber, SalesOrderLineNumber);

-- ColumnStore
SELECT
    * INTO FactInternetSales_CS
FROM
    FactInternetSales;

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactInternetSales_CS_PK ON FactInternetSales_CS;

---------------------------------------------------------------------------------
/*UNIQUE INDEX*/
-- ensures no duplicates values exist in specific columns.
/*
Benefits:
1. enforece uniqueness
2. slightly increase query performance.
 */
-- Using mysql
CREATE UNIQUE INDEX idx_unique_order_mysql ON salesdb.orders (orderid);

-- Using Psql
CREATE UNIQUE INDEX idx_unique_order_psql ON sales.orders (orderid);

-- Uisng mssql
SELECT
    * INTO FactInternetSales_UN
FROM
    FactInternetSales;

CREATE UNIQUE INDEX idx_unique_order_psql ON FactInternetSales_UN (SalesOrderNumber, SalesOrderlineNumber);

/*FILTERED INDEX*/
-- an index that includes only rows meeting the specified conditions.
USE SalesDB;

SELECT
    *
FROM
    sales.customers
WHERE
    country = 'USA';

CREATE NONCLUSTERED INDEX idx_customers_country ON sales.customers (country)
WHERE
    country = 'USA';

---------------------------------------------------------------------------------------------------
/*MANAGING  AND MONITORING INDEXES*/
/*List all indexes on a specific table*/
-- Using mysql 
USE salesdb;

SHOW INDEXES
FROM
    salesdb.orders;

-- List all Indexes in a database
SELECT
    TABLE_NAME AS TableName,
    index_name AS IndexName,
    TABLE_SCHEMA AS DatabaseName,
    COLUMN_NAME AS ColumnName,
    INDEX_TYPE AS IndexType
FROM
    information_schema.STATISTICS
WHERE
    TABLE_SCHEMA = 'salesdb'
    -- Using postegresql
SELECT
    *
FROM
    pg_indexes;

SELECT
    *
FROM
    pg_indexes
WHERE
    tablename = 'customers';

-- Using SQL Server
SELECT
    *
FROM
    sys.tables;

SELECT
    *
FROM
    sys.indexes;

SELECT
    *
FROM
    sys.dm_db_index_usage_stats;

SELECT
    tb.name AS TableName,
    idx.name AS IndexName,
    idx.type_desc AS IndexType,
    tb.create_date AS CreatedOn,
    tb.modify_date AS modifiedOn,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScan,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    COALESCE(last_user_seek, last_user_lookup) LastUpdate
FROM
    sys.indexes idx
    INNER JOIN sys.tables tb ON idx.object_id = tb.object_id
    LEFT JOIN sys.dm_db_index_usage_stats s ON idx.index_id = s.index_id;

-- checking for duplicate indexes
SELECT
    *
FROM
    sys.columns;

SELECT
    tb.name AS TableName,
    col.name AS ColumnName,
    idx.name AS IndexName,
    idx.type_desc IndexType,
    ROW_NUMBER() OVER (
        PARTITION BY
            tb.name,
            col.name
        ORDER BY
            tb.name,
            col.name
    ) AS DuplicateCount
FROM
    sys.indexes idx
    JOIN sys.tables tb ON idx.object_id = tb.object_id
    JOIN sys.index_columns AS idxcol ON idxcol.object_id = idx.object_id
    AND idx.index_id = idxcol.index_id
    JOIN sys.columns AS col ON col.column_id = idxcol.column_id
    AND col.object_id = idxcol.object_id
ORDER BY
    DuplicateCount DESC;

--------------------------------------------------------------------------------
/*Index Fragmentation(mssql) "OR" Index Bloat(mysql , psql)*/
/*
Index fragmentation means that the logical order of index pages no longer matches their physical order on disk, or pages are loosely filled, leading to wasted space and slower query performance. SQL Server provides built-in tools to measure and fix fragmentation, while MySQL and PostgreSQL handle it differently (often referred to as table/index bloat).
 */
-- Using mysql
SHOW TABLE STATUS LIKE "customers";

-- if the number in "Data_free" is large means that space is allocated but unsed.
OPTIMIZE TABLE your_table;

-- Using Psql
-- we need extensions to do this.
CREATE extension pgstattuple;

SELECT
    *
FROM
    pgstatindex ('idx_customerid');

-- check the 'leaf_fragmentation'
-- run to fix the bloat
REINDEX INDEX idx_customerid;

--  Using mssql
SELECT
    tbl.name AS TableName,
    idx.name AS IndexName,
    s.avg_fragmentation_in_percent,
    s.page_count
FROM
    sys.dm_db_index_physical_stats (DB_Id (), NULL, NULL, NULL, 'LIMITED') AS s
    INNER JOIN sys.tables tbl ON s.object_id = tbl.object_id
    INNER JOIN sys.indexes AS idx ON idx.object_id = s.object_id
    AND idx.index_id = s.index_id
ORDER BY
    s.avg_fragmentation_in_percent DESC
    -- When to defragment?
    -- <10% No Action Needed
    -- 10 - 30% Reorganize
    -- > 30% Rebuild
    -- lets assume that "idx_customers_country" have 15% fragmentation (reorganize)
ALTER INDEX idx_customers_country ON sales.customers REORGANIZE;

-- lets assume that "idx_customers_country" have 45% fragmentation (rebuild)
ALTER INDEX idx_customers_country ON sales.customers REBUILD;

--------------------------------------------------------------------------------------------------
/*EXECUTION PLANING*/
-- An execution plan is the detailed strategy the database optimizer chooses to retrieve or modify data for a SQL query.
/*Using SQL Server*/
-- For Non-Clustered Index
USE AdventureWorksDW2022;

SELECT
    *
FROM
    FactResellerSales
WHERE
    CarrierTrackingNumber = '4911-403C-98';

CREATE nonclustered INDEX idx_FactReseller_CTA ON FactResellerSales (CarrierTrackingNumber);

-- For Clustered ColumnStore Index
CREATE clustered columnstore INDEX idx_FactReseller_Sales_HP ON FactResellerSales_HP;

SELECT
    p.EnglishProductName AS ProductName,
    SUM(s.SalesAmount) AS TotalSales
FROM
    FactResellerSales_HP AS s
    JOIN DimProduct AS p ON p.ProductKey = s.ProductKey
GROUP BY
    p.EnglishProductName;

/*Using  Psql and mysql*/
EXPLAIN ANALYSE
SELECT
    *
FROM
    sales.ordersarchive;

EXPLAIN ANALYSE
SELECT
    *
FROM
    sales.ordersarchive
WHERE
    orderid = 6
    AND shipdate > '2024-04-25'
    AND (
        customerid = 3
        OR customerid = 4
    );

CREATE INDEX idx_orderid ON sales.ordersarchive (order_id);

--------------------------------------------------------------------------------------------------
/*Partition in SQL*/
-- it is use to defined how to partition your data (big data tables)
-- very useful for performance optimization in Big Data Warehoused tables.
USE SalesDB;

/*step 1: creating partition function*/
CREATE PARTITION FUNCTION PartitionByYear (DATE) AS RANGE LEFT FOR
VALUES
    ('2023-12-31', '2024-12-31', '2025-12-31');

-- see all partition function in a database
SELECT
    *
FROM
    sys.partition_functions;

/*step 2: creating File Groups*/
-- it is folders where each partition of data is stored.
-- e.g. 4 partitions of data then it will have 4 file group folders.
ALTER DATABASE SalesDB
ADD FILEGROUP FG_2023;

ALTER DATABASE SalesDB
ADD FILEGROUP FG_2024;

ALTER DATABASE SalesDB
ADD FILEGROUP FG_2025;

ALTER DATABASE SalesDB
ADD FILEGROUP FG_2026;

-- Query to list all Filegroup in database
-- there is always a default filegroup where all object of database is stored (is_default = 1).
SELECT
    *
FROM
    sys.filegroups
WHERE
    TYPE = 'FG';

/*step 3: creating Data Files (.ndf) for each FileGroup*/
-- It is the files which actually store data, and it stored physically in the database.
ALTER DATABASE SalesDB
ADD FILE (
    NAME = P_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
) TO FILEGROUP FG_2023;

ALTER DATABASE SalesDB
ADD FILE (
    NAME = P_2024,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
) TO FILEGROUP FG_2024;

ALTER DATABASE SalesDB
ADD FILE (
    NAME = P_2025,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
) TO FILEGROUP FG_2025;

ALTER DATABASE SalesDB
ADD FILE (
    NAME = P_2026,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'
) TO FILEGROUP FG_2026;

-- Quering all the data file in the database
SELECT
    *
FROM
    sys.filegroups;

SELECT
    *
FROM
    sys.master_files;

SELECT
    fg.name AS FileGroupName,
    mf.name AS DataPageName,
    mf.physical_name AS PhysicalPath,
    mf.size / 128 AS SizeInMB
FROM
    sys.filegroups AS fg
    JOIN sys.master_files mf ON fg.data_space_id = mf.data_space_id
WHERE
    mf.database_id = DB_ID ('SalesDB');

/*step 4: Creating Partition Schema*/
-- it maps the data to the filegroup means which partition that data should enter
CREATE PARTITION SCHEME SchemaPartitionByYear AS PARTITION PartitionByYear TO (FG_2023, FG_2024, FG_2025, FG_2026);

-- query list of all partition scheme
SELECT
    *
FROM
    sys.partition_schemes;

SELECT
    *
FROM
    sys.filegroups;

SELECT
    *
FROM
    sys.partition_functions;

SELECT
    *
FROM
    sys.destination_data_spaces;

SELECT
    ps.name AS PartitionSchemaName,
    pf.name AS PatitionFunctionName,
    dds.destination_id AS PartitionNumber,
    fg.name AS FileGroupName
FROM
    sys.partition_schemes ps
    JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
    JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id
    JOIN sys.filegroups fg ON fg.data_space_id = dds.data_space_id;

/*step 4: Creating Partition table*/
CREATE TABLE
    sales.Orders_Partitioned (OrderID INT, OrderDate DATE, Sales INT) ON SchemaPartitionByYear (OrderDate);

/*Inserting data into partition table*/
INSERT INTO
    sales.Orders_Partitioned
VALUES
    (1, '2023-05-15', 1010),
    (2, '2024-05-15', 1080),
    (3, '2025-05-15', 1040),
    (4, '2026-05-15', 1030);

SELECT
    *
FROM
    sales.Orders_Partitioned;

-- Query the no. of row of data in each filegroup
SELECT
    p.partition_number AS PartitionNumber,
    fg.name AS FileGroupName,
    p.rows AS NumberOfRows
FROM
    sys.partitions p
    JOIN sys.destination_data_spaces dds ON dds.destination_id = p.partition_number
    JOIN sys.filegroups fg ON fg.data_space_id = dds.data_space_id
WHERE
    OBJECT_NAME (p.object_id) = 'Orders_Partitioned';

/*PERFORMANCE OF PARTITIONING*/
SELECT
    * INTO sales.Orders_NotPartitioned
FROM
    sales.Orders_Partitioned;

-- partitioned table
SELECT
    *
FROM
    sales.Orders_Partitioned
WHERE
    OrderDate = '2024-05-15';

-- non partitioned table
SELECT
    *
FROM
    sales.Orders_NotPartitioned
WHERE
    OrderDate = '2024-05-15';

------------------------------------------------------------------------------------------
/*Partition of a Already Created Table*/
USE AdventureWorks2022;

SELECT
    *
FROM
    sales.SalesOrderDetail
ORDER BY
    ModifiedDate;

SELECT
    YEAR(ModifiedDate) AS Years,
    MIN(ModifiedDate) AS MinDate,
    MAX(ModifiedDate) AS MaxDate
FROM
    sales.SalesOrderDetail
GROUP BY
    YEAR(ModifiedDate)
ORDER BY
    YEAR(ModifiedDate);

-- Creating Partition Function
CREATE PARTITION FUNCTION PartitionSalesByYear (DATE) AS RANGE LEFT FOR
VALUES
    (
        '2011-12-31',
        '2012-12-31',
        '2013-12-31',
        '2014-12-31'
    );

SELECT
    *
FROM
    sys.partition_functions;

-- Creating FileGroups
ALTER DATABASE AdventureWorks2022
ADD FileGroup FG_2011;

ALTER DATABASE AdventureWorks2022
ADD FileGroup FG_2012;

ALTER DATABASE AdventureWorks2022
ADD FileGroup FG_2013;

ALTER DATABASE AdventureWorks2022
ADD FileGroup FG_2014;

ALTER DATABASE AdventureWorks2022
ADD FileGroup FG_2015;

SELECT
    *
FROM
    sys.filegroups
WHERE
    TYPE = 'FG';

-- Creating Data File (.ndf) for each FileGroups
ALTER DATABASE AdventureWorks2022
ADD FILE (
    NAME = 'DF_2011',
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DF_2011.ndf'
) TO FileGroup FG_2011;

ALTER DATABASE AdventureWorks2022
ADD FILE (
    NAME = 'DF_2012',
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DF_2012.ndf'
) TO FileGroup FG_2012;

ALTER DATABASE AdventureWorks2022
ADD FILE (
    NAME = 'DF_2013',
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DF_2013.ndf'
) TO FileGroup FG_2013;

ALTER DATABASE AdventureWorks2022
ADD FILE (
    NAME = 'DF_2014',
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DF_2014.ndf'
) TO FileGroup FG_2014;

ALTER DATABASE AdventureWorks2022
ADD FILE (
    NAME = 'DF_2015',
    filename = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DF_2015.ndf'
) TO FileGroup FG_2015;

-- Query all the filegroup with there Data files .ndf
SELECT
    fg.name,
    mf.name,
    mf.physical_name,
    mf.size / 128 AS SizeInMB
FROM
    sys.master_files mf
    JOIN sys.filegroups fg ON fg.data_space_id = mf.data_space_id
WHERE
    database_id = DB_ID ('AdventureWorks2022');

-- Creating Partition Scheme 
CREATE PARTITION scheme SchemaSalesPartitionByYear AS PARTITION PartitionSalesByYear TO (FG_2011, FG_2012, FG_2013, FG_2014, FG_2015);

SELECT
    *
FROM
    sys.partition_schemes;

-- Convert Existing Table to Partitioned Table
-- If the table already has a clustered index, "rebuild" it onto the partition scheme.
-- Our table have 'clustered index on SalesOrderId and SalesOrderDetailID'
-- Now, we need to rebuild it
CREATE clustered INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID ON sales.SalesOrderDetail (SalesOrderID, SalesOrderDetailID) ON SchemaSalesPartitionByYear (ModifiedDate);

-- Deleting the already created clustered index (if there's a one)
ALTER TABLE Sales.SalesOrderDetail
DROP CONSTRAINT PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID;

-- The ModifiedDate column has "Datetime" datatype but
-- the partition function "PartitionSalesByYear (DATE)" has date type
ALTER TABLE sales.SalesOrderDetail
ADD ModifiedDate_Date AS CAST(ModifiedDate AS DATE) persisted;

-- rebuilding with ModifiedDate_Date
CREATE clustered INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID ON sales.SalesOrderDetail (SalesOrderID, SalesOrderDetailID) ON SchemaSalesPartitionByYear (ModifiedDate_Date);

-- PERFORMACE TESTING
SELECT
    * INTO sales.SalesOrderDetail_nopartitioned
FROM
    Sales.SalesOrderDetail;

-- For Partitioned Table
SELECT
    *
FROM
    sales.SalesOrderDetail
WHERE
    ModifiedDate_Date = '2013-10-30';

-- For Non Partitioned Table
SELECT
    *
FROM
    sales.SalesOrderDetail_nopartitioned
WHERE
    ModifiedDate_Date = '2013-10-30';