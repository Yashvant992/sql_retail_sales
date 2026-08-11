create database sql_project_p1

create table retail_sales(
   transactions_id	int  primary key,
   sale_date date,
   sale_time time,	
   customer_id int,
   gender varchar(20),	
   age	int,
   category	varchar(50),
   quantiy	int ,
   price_per_unit decimal(10,2),	
   cogs	decimal(10,2),
   total_sale decimal(10,2)
);


-------Data cleaning-------

---check null value in all column

select * from retail_sales_anlysis
where transactions_id is null
   or sale_date is null
   or sale_time is null
   or customer_id is null
   or gender is null
   or age is null
   or category is null
   or quantiy is null
   or price_per_unit is null
   or cogs is null
   or total_sale is null

alter table retail_sales_anlysis
delete from retail_sales_anlysis
where transactions_id is null
   or sale_date is null
   or sale_time is null
   or customer_id is null
   or gender is null
   or age is null
   or category is null
   or quantiy is null
   or price_per_unit is null
   or cogs is null
   or total_sale is null

   -------Data exploration ----------

   --how many rows we have

   select count(*) from retail_sales_anlysis


   ---how many unique customers we have---

   select count(distinct customer_id) from retail_sales_anlysis

   --how many catecory we have---

   select count(distinct category) from retail_sales_anlysis

  ---Data Analysis and Business key problem and answer

  -- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

select * from retail_sales_anlysis
where sale_date='2022-11-05'

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

select * from retail_sales_anlysis
where  (sale_date>='2022-11-01' and sale_date<='2022-11-30') and
    category='Clothing' AND quantiy>=4
     


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

select distinct category,sum(transactions_id) over(partition by category) as total_sale
from retail_sales_anlysis

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select distinct category,AVG(age) over(partition by category) as avg_age
from retail_sales_anlysis
where category='Beauty'
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

select * from retail_sales_anlysis
where total_sale>1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select distinct category,gender,
       count(transactions_id) over(partition by gender ) as total_trans
from retail_sales_anlysis
order by category desc

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

select distinct month(sale_date),avg(total_sale) over(partition by month(sale_date)) as avg_month
from retail_sales_anlysis
order by month(sale_date)

WITH monthlySale AS
(
  select year(sale_date) as years,
  month(sale_date) as monthes,
  AVG(total_sale)  as avg_sale
  from retail_sales_anlysis
  group by YEAR(sale_date),MONTH(sale_date)
),
rankmonthes as(
     select years,monthes,avg_sale,
     rank() over(partition by years order by avg_sale desc) as rk
     from monthlySale
)
select years,monthes,ROUND(avg_sale,2) as avrg_sale
from rankmonthes
where rk=1
order by years



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

select *
from retail_sales_anlysis 
order by total_sale desc
       offset 0 rows fetch next 5 rows only

with top5 as(
      select transactions_id,customer_id,total_sale,
      ROW_NUMBER() over( order by total_sale desc ) as rnk
      from retail_sales_anlysis


)
select  transactions_id,customer_id,total_sale,rnk
from top5
where rnk between 1 and 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select distinct category,count(distinct customer_id )  as total_uni_cust
from retail_sales_anlysis
group by category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


SELECT
    CASE
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) <= 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS Shift,
    COUNT(*) AS nouberOfOders
FROM retail_sales_anlysis
GROUP BY
    CASE
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) <= 17 THEN 'Afternoon'
        ELSE 'Evening'
    END; 
  