/*Request 1: Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region*/

select distinct market AS "List of Markets" from dim_customer where customer = "Atliq Exclusive" AND region = "APAC";

select count(distinct market) from dim_customer where customer = "Atliq Exclusive" AND region = "APAC";

/*Request 2: What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg*/

with product_count_2020 as
(select count(distinct product_code) unique_products_2020 from dim_product 
join dim_date using(product_code) where fiscal_year = "2020"),
product_count_2021 as
(select count(distinct product_code) unique_products_2021 from dim_product 
join dim_date using(product_code) where fiscal_year = "2021")
select unique_products_2020,unique_products_2021,
concat(round((unique_products_2021 - unique_products_2020) / unique_products_2020 * 100,2),"%") percentage_chg
from product_count_2020,product_count_2021;

/*Request 3: Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count*/

select segment, count(distinct product_code) AS product_count from dim_product 
group by segment order by product_count desc;

/*Request 4: Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference*/

WITH product_count_2020 AS (
    SELECT segment, COUNT(DISTINCT product_code) AS product_count_2020
    FROM dim_product
    JOIN dim_date USING (product_code)
    WHERE fiscal_year = "2020"
    GROUP BY segment
),
product_count_2021 AS (
    SELECT segment, COUNT(DISTINCT product_code) AS product_count_2021
    FROM dim_product
    JOIN dim_date USING (product_code)
    WHERE fiscal_year = "2021"
    GROUP BY segment
)
SELECT 
    pc2020.segment,
    pc2020.product_count_2020,
    pc2021.product_count_2021,
    (pc2021.product_count_2021 - pc2020.product_count_2020) AS difference
FROM 
    product_count_2020 AS pc2020
JOIN 
    product_count_2021 AS pc2021 
ON 
    pc2020.segment = pc2021.segment;
    
/*Request 5: Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost*/

select product_code, product, manufacturing_cost from dim_product
join fact_manufacturing_cost using(product_code) 
where manufacturing_cost in
((select max(manufacturing_cost) from fact_manufacturing_cost),
(select min(manufacturing_cost) from fact_manufacturing_cost));

/*Request 6: Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage*/

select fact_pre_invoice_deductions.customer_code, 
       dim_customer.customer, 
       concat(round(avg(pre_invoice_discount_pct) * 100, 2), '%') as average_discount_percentage
from fact_pre_invoice_deductions
join dim_customer on fact_pre_invoice_deductions.customer_code = dim_customer.customer_code
where fiscal_year = 2021 
  and market = "India" 
group by fact_pre_invoice_deductions.customer_code, dim_customer.customer
order by avg(pre_invoice_discount_pct) desc
limit 5;

/*Request 7: Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount*/

select month(date) as Month, 
       fiscal_year as Year, 
       sum(round(gross_price * sold_quantity, 2)) as Gross_Sales_Amount
from fact_gross_price gp
join fact_sales_monthly fsm using (product_code, fiscal_year)
join dim_customer using (customer_code)
where customer = "Atliq Exclusive"
group by month(date), fiscal_year order by month(date);

/*Request 8: In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity*/

select quarter(date) as quarter, 
       sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly
where fiscal_year = 2020 
group by quarter(date)
order by total_sold_quantity desc;

/*Request 9: Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage*/

with cte as 
(
select channel, sum(round((sold_quantity * gross_price) / 1000000, 2)) gross_sales_mln
from dim_customer c
join fact_sales_monthly fsm
using(customer_code)
join fact_gross_price p
on fsm.product_code = p.product_code and fsm.fiscal_year = p.fiscal_year
where p.fiscal_year = 2021
group by channel
)
select channel, gross_sales_mln, concat(round(100 * (gross_sales_mln/sum(gross_sales_mln) over()), 2), "%") percentage
from cte
group by channel;

/*Request 10: Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
product
total_sold_quantity
rank_order */

WITH cte AS (
    SELECT 
        dim_product.division, 
        dim_product.product_code, 
        dim_product.product, 
        DENSE_RANK() OVER (PARTITION BY division ORDER BY SUM(sold_quantity) DESC) AS "rank_order",
        SUM(fact_sales_monthly.sold_quantity) AS total_sold_quantity
    FROM dim_product
    JOIN fact_sales_monthly 
        ON dim_product.product_code = fact_sales_monthly.product_code
    WHERE fiscal_year = 2021
    GROUP BY dim_product.division, dim_product.product_code, dim_product.product
)
SELECT 
    division, 
    product_code, 
    product, 
    total_sold_quantity,
    rank_order
FROM cte
WHERE "rank_order" < 4;
















    







