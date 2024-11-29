use gdb023;
show tables;

select * from dim_customer limit 5;

select count(customer_code) from dim_customer;

select count(distinct customer) from dim_customer;
select distinct customer from dim_customer;

select distinct platform from dim_customer;

select distinct channel from dim_customer;

select distinct market from dim_customer;
select count(distinct market) from dim_customer;

select distinct sub_zone from dim_customer;
select count(distinct sub_zone) from dim_customer;

select distinct region from dim_customer;

select * from dim_product limit 5;

select count(distinct product_code) from dim_product;

select count(distinct product) from dim_product;
select distinct product from dim_product;

select distinct division from dim_product;

select distinct segment from dim_product;

select distinct category from dim_product;
select count(distinct category) from dim_product;

select distinct variant from dim_product;
select count(distinct variant) from dim_product;

select * from fact_gross_price limit 5;

select distinct fiscal_year from fact_gross_price;

select sum(gross_price) AS "Total Gross Price" from fact_gross_price;

select * from fact_manufacturing_cost limit 5;

select sum(manufacturing_cost) AS "Total Manufacturing Cost" from fact_manufacturing_cost;

select * from fact_pre_invoice_deductions limit 5;

select sum(pre_invoice_discount_pct) AS "Total Pre Invoice Deductions " from fact_pre_invoice_deductions;

select * from fact_sales_monthly limit 5;

select sum(sold_quantity) AS "Total Sold Quantity" from fact_sales_monthly;

create table dim_date as (select date,fiscal_year,product_code,customer_code from fact_sales_monthly);

select * from fact_sales_monthly;











