/* Analayis of sales in different paper types */




/* 1. First, lets see how much we sale per year */

/* Selecting year using extract function & giving an alias name,
   and sum of the total amount used using aggregate function sum() and giving an alias name, 
   from the orders table and grouping it by the year and sorting it by the total amount ascendingly */

SELECT EXTRACT(YEAR FROM occurred_at) AS year,   
SUM(total_amt_usd) AS total_usd                 
FROM orders
GROUP BY year
ORDER BY total_usd ASC;

/*  2. Providing the region for each sales_rep along with their associated accounts for the 'Midwest' region only.*/

--As we want the region name, the sales rep name and the account name, we have to work with 3 tables: regions, sales_reps and accounts
--So we select the name column from the regions table, the name column from the sales_reps table and the name column from the accounts table
--Then we join the region table with the sales_reps table and that with the account tables
-- As we only want the Midwest region, we filter with a where clause
-- And finally we sort by the account name 

SELECT r.name as Region, sr.name as Rep_name, acc.name as account_name
FROM orders ord join region r on r.id=ord.region_id 
				join sales_reps sr on sr.id=ord.sales_reps_id
				join accounts acc on acc.id=ord.account_id
WHERE r.name='Midwest'
ORDER BY acc.name ASC


-- 3.Lets see the percentage of growth in each year in the last quarter.

--We extract the year of the occurred_at column from the orders table ,we  extract the month, and we also extract the day. 
--Apply the sum() function to the total_amt_usd also from the orders table and give an alias name
--We filter by where clause with month and day by any conditions.
--We group by year,month and day and sort it by the total amount used.

WITH CTE_GROWTH AS 
(SELECT EXTRACT(YEAR FROM occurred_at) AS year, 
 		EXTRACT(MONTH FROM occurred_at) AS month,  
 		EXTRACT(DAY FROM occurred_at) AS day,
		SUM(total_amt_usd) AS total_usd
FROM orders
WHERE EXTRACT(MONTH FROM occurred_at) IN (9) AND EXTRACT(DAY FROM occurred_at) = 1
GROUP BY year, month, day
ORDER BY month asc ) 

SELECT year, month, day,total_usd,
total_usd - LAG(total_usd) OVER (ORDER BY year ASC) AS growth,
(total_usd - LAG (total_usd) OVER (ORDER BY year ASC))/LAG (total_usd) OVER (ORDER BY year ASC)*100 AS percentage_growth
FROM CTE_GROWTH



/* 4.For each account,determining the average amount of each type of paper they purchased across their orders.*/

--We need the column name of the accounts table, and the mean of each type of paper each one of the accounts purchased
--Thus, we apply the aggregate function avg() in each type of paper
--As we want the account name and the mean of each type of paper each one of the accounts purchased across their orders
--we join the accounts table with the orders table
--Lastly we group by the account_name

CREATE VIEW  average_amount AS (
	SELECT ac.name AS account_name, AVG(o.standard_qty) AS average_standard_qty, AVG(o.gloss_qty) AS average_gloss_qty, 
	AVG(o.poster_qty) AS average_poster_qty, AVG(total) as average_total
	FROM accounts ac JOIN orders o ON ac.id=o.account_id 
	GROUP BY ac.name
	ORDER BY average_standard_qty DESC )

-- View created and named as average_amount 

SELECT account_name , ROUND(average_standard_qty,2) AS average_standard_qty ,
ROUND(average_gloss_qty,2) AS average_gloss_qty ,ROUND(average_poster_qty,2) AS average_poster_qty,
ROUND(average_total,2) AS average_total 
FROM average_amount;


/* 5.For each account, determining the average amount spent per order on each paper type. */

--Selecting the name of the acccounts from accounts table, &the mean of the amount spent on each paper type by the respective acocounts
--Thus, we apply the aggregate function avg() on the amount spent on each paper type.
--As we want the account name and the mean of the amount spend on each type of paper 
--we join the accounts table with the orders table
--Lastly we group by the account_name and sort it.

SELECT ac.name AS account_name, 
AVG(o.standard_amt_usd) AS avg_standard_amt_usd, 
AVG(o.gloss_amt_usd) AS avg_gloss_amt_usd,
AVG(o.poster_amt_usd) AS avg_poster_amt_usd,
AVG(o.standard_amt_usd)+AVG(o.gloss_amt_usd)+AVG(o.poster_amt_usd) as total
FROM accounts ac JOIN orders o ON ac.id=o.account_id 
GROUP BY ac.name
ORDER BY total DESC

/* 6. Using the above question , find the account that had spend the maximum */

-- Using the above in a Subquery we find the the account of the company that has spent the most.
--The Subquery here is given an alias name 'A' and limitting it by 1 to know the maximum spent account.
--In this query we can visualize the account_name that had spend the most 

SELECT account_name, ROUND(avg_standard_amt_usd) AS avg_standard_amt_usd,ROUND(avg_gloss_amt_usd) AS avg_gloss_amt_usd,
ROUND(avg_poster_amt_usd) AS avg_poster_amt_usd,ROUND(total) AS total
FROM (	SELECT ac.name AS account_name, AVG(o.standard_amt_usd) AS avg_standard_amt_usd, AVG(o.gloss_amt_usd) AS avg_gloss_amt_usd,
		AVG(o.poster_amt_usd) AS avg_poster_amt_usd, AVG(o.standard_amt_usd)+AVG(o.gloss_amt_usd)+AVG(o.poster_amt_usd) as total
		FROM accounts ac JOIN orders o ON ac.id=o.account_id 
		GROUP BY ac.name
		ORDER BY total DESC) A
LIMIT 1;

/* 7. Determining the number of times a particular channel was used in the web_events table for each sales rep. 
Order your table with the highest number of occurrences first.*/

--We want the sales rep name, the channel and the number of occurrences of these channels 
--To attain those we will work with web_events table, the sales_reps table and the orders table.
--Therefore,selecting the name column from the sales_reps table, the channel column from the web_events table,
--and apply the count() function to the channels to get the number of occurences.
--Then, as we are working with the web_events and sales_reps tables we want to join them. 
--We'll join them using orders table which is the only common between the tables.
--We then group by the sales rep name and the channel and finally  sort by the number of ocurrences 

SELECT sr.name AS sales_rep_name, we.channel AS channel, count(channel) AS number_of_occurrences
from web_events we join orders ord on we.id=ord.web_events_id 
				   join sales_reps sr on sr.id=ord.sales_reps_id
GROUP BY sr.name, we.channel
ORDER BY number_of_occurrences DESC

/* 8. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
for the order. However, only provide the results if the standard order quantity exceeds 100 and the poster order quantity
exceeds 50. */

--Here we sort the table to visualize the account name with the lowest unit price 
--In order to avoid a division by zero error, adding .01 to the denominator 

SELECT r.name as region, ac.name as account_name, round((o.total_amt_usd/(o.total + 0.01)),2) as unit_price
FROM region r join orders o on r.id=o.region_id
			  join accounts ac on ac.id=o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price ASC

/* 9. Using the above question, display only the account name with HIGHEST unit price */

--Here we sort the table to visualize the account name with the highest unit price using DESC

SELECT r.name as region, ac.name as account_name, round((o.total_amt_usd/(o.total + 0.01)),2) as unit_price
FROM region r join orders o on r.id=o.region_id
			  join accounts ac on ac.id=o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC
LIMIT 1;



/* 10. To find out which paper has sold the most across companies and the total amount used on the respective types */

--To fine the quantity ordered of every type of paper
--To do this, we have to perform sum() function on the paper types quantity to find the total.

SELECT SUM(standard_qty) AS total_standard_qty, 
SUM(gloss_qty) AS total_gloss_qty, 
SUM(poster_qty) AS total_poster_qty 
FROM orders

/* 11.  To find how much money was spend in each type of paper */

--To do this,we have to perform sum() function on the amount spent in each paper type.

SELECT SUM(standard_amt_usd) AS total_standard_usd, 
SUM(gloss_amt_usd) total_gloss_usd, 
SUM(poster_amt_usd) AS  total_poster_usd 
FROM orders

/* 12. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?*/

--Selecting the year,month using extract() function, the total gloss amount using sum() from orders table and account name from accounts table
--We attain the required by joining these two tables on acccount id.
--TO get the result specific to 'Walmart', we filter using WHERE clause
--Finally we group by the year,name,name and sort it by the total gloss usd in descending order
--We limit the output to 1 to get which month had the highest spendings.

SELECT EXTRACT(YEAR FROM o.occurred_at) as year, EXTRACT( MONTH FROM o.occurred_at) AS MONTH,
ac.name AS account_name, SUM(gloss_amt_usd) AS total_gloss_usd 
FROM orders o JOIN accounts ac
ON o.account_id=ac.id
WHERE ac.name='Walmart'
GROUP BY YEAR,MONTH,NAME
ORDER BY total_gloss_usd DESC
LIMIT 1


/* 13.Providing the region for each sales_rep along with their associated accounts.
This time only for accounts where the sales rep has a first name starting with S and in the Midwest region.*/

--The condition for the first name of the sales rep name should starts with an S.
--Therefore, in the where clause we a condition

SELECT r.name as Region, sr.name as Rep_name, ac.name as account_name
FROM orders o JOIN region r ON r.id=o.region_id
		      JOIN sales_reps sr ON sr.id=o.sales_reps_id 
			  JOIN accounts ac ON o.account_id=ac.id
WHERE r.name='Midwest' AND sr.name LIKE 'S%'
ORDER BY ac.name ASC


/* 14. To find the maximum amount spent by a particular account across the years and it's corresponding name & id  */

--To do this,we have to join orders and accounts tables.
--To find the specific company that had spent the maximum, we have to use sum() function for total_amt_us
--The sum() is used in an subquery to find the maximum and finally, the result is grouped by name & id.

SELECT o.account_id,ac.name AS account_name,SUM(total_amt_usd) AS Total_Amount
FROM orders o JOIN accounts ac ON o.account_id=ac.id
GROUP BY account_id,ac.name
HAVING SUM(total_amt_usd) >= 
ALL(SELECT SUM(total_amt_usd) FROM orders GROUP BY account_id);

/* 15. With respective to 2016 , determining the total quantity of papers 
       and the total amount used on all types across region.*/

-- Firstly, we have to join region and orders table to relate the paper details with region.
--By extracting year from occurred_at, using SUM () function we can find the total quantity and total amount.
--Finally, we can filter year using WHERE clause and group it by region.


SELECT r.name AS region_name ,EXTRACT(YEAR FROM occurred_at) AS year,
ROUND(SUM(total)) AS Total_quantity,
ROUND(SUM(total_amt_usd)) AS Total_amount
FROM orders o JOIN region r
ON o.region_id=r.id
WHERE EXTRACT(YEAR FROM occurred_at) = 2016
GROUP BY r.name,year












