show databases;

-- connect to database
use mydatabase;

-- Print intire table.
select * from salesdb.customers;

-- Describing tables Structure
desc salesdb.customers;

select * from mydatabase.customers;

-- select entire table
select first_name, score from mydatabase.customers;

-- Where in sql
select * from mydatabase.customers where score > 500;

select * from mydatabase.customers where score != 0;

select * from mydatabase.customers where country = "Germany";

-- Order by in sql
select * from mydatabase.customers Order by score asc;

select * from mydatabase.customers Order by score desc;

select *
from mydatabase.customers
Order by country asc, score desc;

-- group by in sql
select country, avg(score) as average_score
from mydatabase.customers
group by
    country;

select
    country,
    sum(score) as total_score,
    count(id) as total_customers
from mydatabase.customers
group by
    country

-- Having clause in sql
/*Filter data after aggregation, can be only used with group by*/
select
    country,
    sum(score) as total_score,
    count(id) as total_customers
from mydatabase.customers
group by
    country
having
    total_score > 800;

/* Ques: Find the average score of each country considering 
only customers with score not equal to 0 and return only those countries with an average score greater than 430*/
select country, avg(score) as average_score
from mydatabase.customers
where
    score != 0
group by
    country
having
    average_score > 430;

-- Distinct in sql
select Distinct country from mydatabase.customers;

-- limit in sql
/*Used to restrict the table rows to return*/
select * from mydatabase.customers limit 3;

-- Ques: Retrieve the top 3 customer with highest scores
select id, first_name, score
from mydatabase.customers
order by score desc
limit 3;

-- Ques: Get the tow most recent orders
select * from mydatabase.orders order by order_date desc limit 3;

-- Static Values in sql
select id, first_name, "new customer" as customer_type
from mydatabase.customers;

-- Create in sql
use mydatabase;

create table if not exists persons (
    id int not null,
    person_name varchar(50) not null,
    birth_date date,
    phone varchar(15) not null,
    constraint pk_persons primary key (id)
)

select * from persons;

-- Alter in sql

-- Add new column
alter table persons add email varchar(50) not null;

-- remove the column
alter table persons drop column phone;

-- rename the column
alter table persons rename column email to emails;

-- Modify datatype of column
alter table persons modify column emails varchar(60);

-- Drop in sql (Risky)
drop table persons;

show tables;

-- DML (Data Manipulation Language)
-- Insert in Sql
insert into
    customers (
        id,
        first_name,
        country,
        score
    )
Values (6, "Anna", "USA", NULL),
    (7, "Sam", NULL, 100);

select * from customers;

insert into
    customers (
        id,
        first_name,
        country,
        score
    )
Values (8, 'USA', 'Max', NULL);

insert into
    customers (
        id,
        first_name,
        country,
        score
    )
Values (9, 'Andreas', 'Germany', NULL);

insert into customers (id, first_name) Values (10, 'Sahra');

-- Inserting Data using other columns (customer to persons)
create table persons ( select * from customers );

select * from persons;

-- endter data using insert command
truncate persons;

desc persons;

insert into
    persons (
        id,
        first_name,
        country,
        score
    ) (
        select *
        from customers
    );

insert into
    persons (id, first_name) (
        select id, first_name
        from customers
    );

-- Upadate in SQL
update customers set score = 0 where id = 6;

select * from customers;

update customers set score = 0, country = 'UK' where id = 10;

-- Delete in Sql (Always where clause)
delete from persons;

select * from persons;

delete from persons where id > 5;

-- 