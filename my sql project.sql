--  Project Overview
-- project name: walmart sales data analysis
-- RDBMS   : MySQL 8.0+ (also compatible with MariaDB 10.x)
-- Notes   : Every ANSWER below each query is a comment showing what that query returns when run against the sample data in
-- Contents:
--      PART 1  : Database & Table Creation (schema)
--      PART 2  : Sample Data (INSERT statements
--      part 3: few numeric ang aggregate functions queries
--      PART 4  : Views
--      PART 5  : Stored Procedures
--      part 6  : joins and joins with clauses
--      part 7  : queries on aggrigate functions with lauses and conditional statements
--      part 8  : triggers with audit table

CREATE TABLE sales (
    invoice_id VARCHAR(30) PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

select*from sales;



--  ---------------------------------------------------------------------------------------------------------------------------------------
--  ------------------------------------------------------feature Engeneering---------------------------------------------------------------

-- time_of_day

SELECT
	time,
    (CASE
         WHEN Time < "12:00:00" THEN "MORNING"
		 WHEN Time BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON" 
		 ELSE "EVENING"
   END
   )AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(30);

UPDATE sales 
SET time_of_day = CASE
    WHEN time < '12:00:00' THEN 'MORNING'
    WHEN time BETWEEN '12:00:00' AND '18:00:00' THEN 'AFTERNOON'
    ELSE 'EVENING'
END
WHERE invoice_id IS NOT NULL;
-- day_name

SELECT
     date,
     DAYNAME(DATE) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = DAYNAME(date);

-- month_name

select
	date,
     MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name=MONTHNAME(DATE);
-- ------------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------ GENERIC ---------------------------------------------------------------------------------

-- HOW MANY UNIQUE CITIES DOES THE DSTS HAVE?
SELECT
     DISTINCT city
FROM sales;
-- in which city is each branch
SELECT
     DISTINCT branch
FROM sales;



select
      DISTINCT city,
      branch
from sales;



-- ------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------ product ---------------------------------------------------------------------

-- how many unique product lines does the data have
select
  distinct product_line
from sales;

select
  count(distinct product_line)as products
from sales;

-- what is the most common payment method?
select
    payment_method
from sales;

select
   payment_method,
   count(payment_method)as no_of_modes
from sales
group by payment_method
order by no_of_modes desc;

-- what is the most selling product line?
select
   product_line,
   count(product_line)as most_selling_product_line
from sales
group by product_line
order by most_selling_product_line desc;

-- what is total revenue by month
select
   month_name as month,
   SUM(TOTAL) AS TOTAL_REVENUE
   from sales
   GROUP BY month_name
   order by total_revenue;
-- which month had the largest cogs
select
   month_name as month,
   sum(cogs) as cogs
   from sales
   group by month_name
   order by cogs;
   
   -- what product line had the largest revenue?
   select
        product_line,
        sum(total) as total_revenue
	from sales
    group by product_line
    order by total_revenue desc;
    
    -- what is the city with largest revenue?
    select
        branch,
        city,
        sum(total) as total_revenue
	from sales
    group by city,branch
    order by total_revenue desc;
    
    -- what product line had the largest vat?
    select
         product_line,
         avg(vat)as avg_tax
         from sales
         group by product_line
         order by avg_tax desc;
         
       -- which product sold more products than average product sold?
       select
            branch,
            SUM(quantity)AS QTY
            from sales
            group by branch
            having sum(quantity)> (select avg(quantity) from sales);
            
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------- views ---------------------------------------------------------------------
-- branch wise revenue and performance view
create view ww_branch_sales_summary as
select
   branch,
   city,
   count(invoice_id) as total_transactions,
   sum(quantity) as total_quantity_sold,
   sum(total) as total_revenue,
   avg(total) as average_order_value
   from sales
   group by branch, city;
  -- filter for a specific branch making the most revenue 
   select
         * 
	from ww_branch_sales_summary
    order by total_revenue desc;
    
    -- customer type and payment method view
     create view ww_customer_payment_behavior as
     select
          customer_type,
          payment_method,
          count(invoice_id) as transaction_count,
          sum(total) as total_spent
	from sales
    group by customer_type, payment_method;
    -- check payment preference from members only
    select*from ww_customer_payment_behavior
    where customer_type='member';
    -- productline performance & probability view
    create or replace view ww_product_profitability as
    select
          product_line,
          sum(quantity) as units_sold,
          sum(total) as total_revenue,
          sum(gross_income) as total_gross_income,
          avg(rating) as average_rating
	from sales
    group by product_line;
    -- find the top performing product line by gross income
    select*from ww_product_profitability 
    order by total_gross_income desc;
    
    -- monthly trend analysis view
    create view ww_monthly_trend as
    select
         month_name,
         count(invoice_id) as monthly_orders,
         sum(total) as monthly_revenue,
         sum(cogs) as monthly_cogs
         from sales
         group by month_name;
         
         -- view monthly trends ordered by heighest revenue
         select*from ww_monthly_trend
         order by monthly_revenue desc;
         
         --- gender wise shopping and basket size view
         create view ww_gender_shopping_behavior as
    select
         gender,
         count(invoice_id) as total_orders,
         avg(quantity) as avg_items_per_order,
         avg(total) as avg_amount_spent,
         sum(total)as cumilative_revenue
         from sales
         group by gender;
         
         select*from ww_gender_shopping_behavior;
-- low rated products view
create view ww_product_ratings_summary as
select
     product_line,
     count(invoice_id)as total_reviews,
     avg(rating) as avg_rating,
     sum(total) as total_revenue
     from sales
     group by product_line;
     
    -- ratings with avg ratings
     select*from ww_product_ratings_summary
     where avg_rating<7.0
     order by avg_rating asc;
     DROP VIEW IF EXISTS ww_high_value_transactions;
     CREATE VIEW vw_transaction_tiers AS
SELECT 
    invoice_id,
    branch,
    customer_type,
    product_line,
    total,
    payment_method,
    date,
    CASE 
        WHEN total >= 3.50 THEN 'High Value (Top Tier)'
        WHEN total >= 2.50 THEN 'Medium Value (Average)'
        ELSE 'Standard Value'
    END AS value_category
FROM sales;
	
    select*from vw_transaction_tiers
    order by total desc;
    
    
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------stored procedures --------------------------------------------------------------
delimiter //
create procedure GetSalesByBranch(in input_branch varchar(5))
begin
    select
         invoice_id,
         branch,
         city,
         product_line,
         total,
         date,
         payment_method
		from sales
        where branch = input_branch;
        end//
        
      drop procedure if exists GetSalesByBranch;
	---- stored procedure with an input parameter
delimiter //
create procedure GetSalesByBranch(in input_branch varchar(5))
begin
    select
         invoice_id,
         branch,
         city,
         product_line,
         total,
         date,
         payment_method
		from sales
        where branch = input_branch;
        end//
        delimiter ;
        
        call GetSalesByBranch('A');
-- stored procedure with multiple inputs
DELIMITER //

CREATE PROCEDURE getSalesByMultipleInputs(
    IN input_month VARCHAR(45),
    IN input_customer_type VARCHAR(45)
)
BEGIN
    SELECT 
        customer_type,
        product_line,
        total,
        month_name
    FROM 
        sales
    WHERE 
        month_name = input_month
        AND customer_type = input_customer_type;
END //

DELIMITER ;
call getSalesByMultipleInputs('march','member');

-- total revenue calculation

delimiter //
create procedure getproductrevenue(
in input_product varchar(100),
out total_rev decimal(15,2)
)
begin
   select round(sum(total))
   into total_rev
   from sales
   where product_line= input_product;
   end//
   delimiter ;
   
   call getproductrevenue('health and beauty', @rev);
   select @rev as calculated_revenue;
-- for paymenth method

delimiter //
create procedure getpaymentsummary(
in input_method varchar(15))
begin
    select
        payment_method,
        count(invoice_id)as total_transactions,
        sum(total) as total_revenue,
        avg(total)as avg_transaction_value
        from sales
        where payment_method=input_method
        group by payment_method;
        end//
        delimiter ;
        call getpaymentsummary('cash');
        
-- branch performance tier
delimiter //
create procedure evaluateperformance(
in input_branch varchar(5),
out performance_status varchar(50)
)
begin
   declare branch_total decimal(12,2);
   select sum(total)into branch_total
   from sales
   where branch=input_branch;
   if branch_total > 50.00 then
      set performance_status = 'high volume branch';
      else
      set performance_status='standard volume branch';
      end if;
	end//
    delimiter ;
    call evaluateperformance('A' ,@status);
    select @status as branch_evaluation
-- filter by date
    delimiter //
create procedure getsalesbydate( in input_date date)
begin
  select
     invoice_id,
     branch,
     product_line,
     quantity,
     total,
     time
     from sales
     where date = input_date;
     end//
     delimiter ;
     call getsalesbydate('2019-02-27');
     -- -------------------------------------------------------------------------------------------------------------------------------------
     -- -------------------------------------------------------joins------------------------------------------------------------------------
     CREATE TABLE branch_targets (
    branch VARCHAR(5) PRIMARY KEY,
    city VARCHAR(50),
    target_revenue DECIMAL(10,2),
    manager_name VARCHAR(50)
);
INSERT INTO branch_targets (branch, city, target_revenue, manager_name) VALUES
('A', 'Yangon', 500.00, 'Aung San'),
('B', 'Mandalay', 450.00, 'Su Su'),
('C', 'Naypyidaw', 600.00, 'Min Aung');

CREATE TABLE promotions (
    product_line VARCHAR(100) PRIMARY KEY,
    discount_percentage DECIMAL(5,2),
    promo_code VARCHAR(20)
    );
INSERT INTO promotions (product_line, discount_percentage, promo_code) VALUES
('Health and beauty', 10.00, 'HEALTH10'),
('Electronic accessories', 5.00, 'ELEC5'),
('Sports and travel', 15.00, 'SPORT15');
-- inner joins
select
    s.invoice_id,
    s.branch,
    b.city,
    s.product_line,
    s.total,
    b.target_revenue
from sales s
inner join branch_targets b
on s.branch = b.branch;

-- left join
select
 s.invoice_id,
 s.branch,
 s.product_line,
 s.total,
 p.discount_percentage,
 p.promo_code
 from sales s
 left join promotions p
 on s.product_line = p.product_line;
-- right join
select
  b.branch,
  b.manager_name,
  b.target_revenue,
  s.invoice_id,
  s.total
  from sales s
  right join branch_targets b
  on s.branch=b.branch;
  -- full outer join
  select
      s.invoice_id,
      s.product_line,
      s.total,
      p.promo_code
      from sales s 
     left join promotions p on s.product_line = p.product_line
     union
     select
         s.invoice_id,
      s.product_line,
      s.total,
      p.promo_code
      from sales s
      right join promotions p on s.product_line = p.product_line;
      
      -- Filter only 'Member' customer transactions, join the branch targets, group by branch and city,
      -- filter branches that generated a total revenue above a specific threshold using HAVING, 
      -- and sort the results from highest to lowest revenue.
select 
   b.branch,
   b.city,
   count(s.invoice_id)as total_transaction,
   sum(s.total) as total_revenue
   from branch_targets b
   inner join sales s on b.branch = s.branch
   where s.customer_type = 'member'
   group by b.branch, b.city
   having sum(s.total) > 100.00
   order by total_revenue desc;
-- Join the sales table with the promotions table to check cash transactions, group them by product line and promotion code,
-- ilter product lines with more than 5 transactions, and sort by the average sale amount.
select
   s.product_line,
   p.promo_code,
   count(s.invoice_id)as transaction_count,
   avg(s.total)as avg_sale_amt
   from sales s 
   left join promotions p
   on s.product_line = p.product_line
   where s.payment_method = 'cash'
   group by s.product_line, p.promo_code
   having count(s.invoice_id) >5
   order by avg_sale_amt desc;
  -- ----------------------------------------------------------------------------------------------------------------------------------------
  -- -----------------------------------------------------aggregate functions----------------------------------------------------------------
  -- count() - count total sales transactions
  select city, count(*)as total_transactions
  from sales
  where customer_type='member'
  group by city;
  
  
  -- sum()
  select city,sum(quantity)as total_sales
  from sales
  group by city;
  
  
  -- find product lines with avg rating above 7 using having
  select product_line, avg(rating)as
  avg_rating
  from sales
  group by product_line
  having avg_rating>7;
  
  
  -- select cities where totaal sales are greater than 10000
  select city,sum(total)as total_sales
  from sales
  group by city
  having total_sales>100.00;
  
  
  -- find highest unit price for female customers
  select product_line,max(unit_price)as highest_price 
  from sales
   where gender = 'Female'
  group by product_line;
  
  
  -- find gross income for each product line
  select product_line,
  round(avg(gross_income), 2)as
  avg_income
  from sales
  group by product_line
  order by avg_income desc;
  
  -- find payment_method used more than 20 times
  select payment_method, count(*) as
  payment_method
  from sales
  group by payment_method
  having count(*) > 30
  order by payment_method desc;
  
  -- find total quantity sold for transactions with qty greater than 5
  select product_line, sum(quantity)as
  total_quantity
  from sales
  group by product_line
  having total_quantity>80
  order by total_quantity desc;
  
  -- classify total sales by city
  select city,
          sum(total) as total_sales,
          case
              when sum(total) >= 100
	then 'high sales'
              when sum(total) >= 50
	then 'medium sales'
              else 'low sales'
		end as sales_category
	from sales
    where customer_type='member'
    group by city
    having sum(total)>90
    order by total_sales desc;
    
  -- classify avg rating by product line
  SELECT product_line,
       ROUND(AVG(rating), 2) AS avg_rating,
       CASE
           WHEN AVG(rating) >= 8 THEN 'Excellent'
           WHEN AVG(rating) >= 6 THEN 'Good'
           ELSE 'Average'
       END AS performance
FROM sales
WHERE gender = 'Female'
GROUP BY product_line
HAVING AVG(rating) > 5
ORDER BY avg_rating DESC;

-- classify purchase qty by city
SELECT city,
       SUM(quantity) AS total_quantity,
       CASE
           WHEN SUM(quantity) >= 500 THEN 'Bulk Sales'
           WHEN SUM(quantity) >= 300 THEN 'Medium Sales'
           ELSE 'Low Sales'
       END AS purchase_category
FROM sales
WHERE quantity >= 2
GROUP BY city
HAVING SUM(quantity) > 100
ORDER BY total_quantity DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------triggers and audit table-----------------------------------------------------------------------
create table if not exists sales_audit(
      audit_id int auto_increment primary key,
      invoice_id varchar(50),
      action_message varchar(100),
      action_time timestamp default current_timestamp
      );
  -- before triggers
  delimiter //
  create trigger trg_simple_total
  before insert on sales
  for each row
  begin
      SET NEW.total = NEW.unit_price * NEW.quantity;
END//
delimiter ;
    
  SELECT invoice_id, unit_price, quantity, total 
FROM sales 
WHERE invoice_id = 'INV-CHECK-01';
INSERT INTO sales (invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, cogs, vat, payment_method, date, time, rating) 
VALUES ('INV-CHECK-01', 'A', 'Yangon', 'Member', 'Female', 'Electronic accessories', 50.00, 4, 200.00, 10.00, 'Cash', '2019-02-27', '12:00:00', 4.5);
SELECT invoice_id, branch, city, gender, unit_price, quantity, cogs, vat, total 
FROM sales 
WHERE invoice_id = 'INV-CHECK-01';

-- auto upper case branch code
delimiter //
create trigger trg_upper_case
before insert on sales
for each row
begin
     set new.branch = upper(new.branch);
     end//
     delimiter ;
     INSERT INTO sales (invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, cogs, vat, total, payment_method, date, time, rating) 
VALUES ('INV-002', 'b', 'Mandalay', 'Normal', 'Male', 'Sports and travel', 80.00, 3, 240.00, 12.00, 252.00, 'Ewallet', '2019-02-28', '14:30:00', 4.0);

-- before update
DELIMITER //

DROP TRIGGER IF EXISTS trg_before_update_sales//

CREATE TRIGGER trg_before_update_sales
BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    -- Automatically recalculate total and cogs on update
    SET NEW.total = NEW.unit_price * NEW.quantity;
    SET NEW.cogs = NEW.unit_price * NEW.quantity;
    SET NEW.vat = NEW.total * 0.05;
    
    -- Example validation: Prevent changing branch to an unauthorized value
    IF NEW.branch NOT IN ('A', 'B', 'C') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Invalid branch code update.';
    END IF;
END//

DELIMITER ;

INSERT INTO sales (invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, cogs, vat, payment_method, date, time, rating) 
VALUES ('INV-001', 'A', 'Yangon', 'Member', 'Female', 'Electronic accessories', 150.00, 2, 300.00, 15.00, 'Cash', '2019-02-27', '10:15:00', 4.5);

-- Update the quantity and unit price for an existing record
UPDATE sales 
SET unit_price = 160.00, quantity = 3 
WHERE invoice_id = 'INV-001';

SELECT invoice_id, unit_price, quantity, cogs, vat, total 
FROM sales 
WHERE invoice_id = 'INV-001';

CREATE TABLE IF NOT EXISTS sales_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id VARCHAR(50) NOT NULL,
    action_message VARCHAR(255) NOT NULL,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    -- after insert
    DELIMITER //

DROP TRIGGER IF EXISTS trg_audit_after_insert//

CREATE TRIGGER trg_audit_after_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    INSERT INTO sales_audit (invoice_id, action_message)
    VALUES (NEW.invoice_id, CONCAT('New sale inserted for Branch ', NEW.branch, ' (Total: ', NEW.total, ')'));
END//

DELIMITER ;
INSERT INTO sales (invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, cogs, vat, total, payment_method, date, time, rating) 
VALUES ('INV-AUDIT-01', 'A', 'Yangon', 'Member', 'Female', 'Electronic accessories', 100.00, 2, 200.00, 10.00, 210.00, 'Cash', '2019-02-27', '11:00:00', 4.5);

SELECT * FROM sales_audit 
WHERE invoice_id = 'INV-AUDIT-01';

-- after update
DELIMITER //

DROP TRIGGER IF EXISTS trg_audit_after_update//

CREATE TRIGGER trg_audit_after_update
AFTER UPDATE ON sales
FOR EACH ROW
BEGIN
    INSERT INTO sales_audit (invoice_id, action_message)
    VALUES (NEW.invoice_id, CONCAT('Sale updated. Old Total: ', OLD.total, ' -> New Total: ', NEW.total));
END//

DELIMITER ;

UPDATE sales 
SET unit_price = 120.00, total = 120.00 * quantity, vat = (120.00 * quantity) * 0.05 
WHERE invoice_id = 'INV-AUDIT-01';

SELECT * FROM sales_audit 
WHERE invoice_id = 'INV-AUDIT-01';