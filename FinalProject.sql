-- 1. How big is the customer base of Parch and Posey (i.e. how many customers/accounts does the company have?) (1 point)
select count(distinct(id)) no_of_customers from accounts;

-- 2. How many areas do they sell at? (1 point)
select count(distinct(id))no_of_regions from region;
select name from region order by name;

-- 3. Look into the revenue streams:
--a. How many types of paper do they sell and what percentage each one of
--them makes out of the total quantity sold? Provide a visualization that
--illustrates the results (e.g. pie chart, bar plot, or any chart of your choice)(1.5 point)
select round(100*sum(standard_qty)/sum(total),2) as standard_qty_pct,
round(100*sum(gloss_qty)/sum(total),2) as gloss_qty_pct,
round(100*sum(poster_qty)/sum(total),2) as poster_qty_pct
from orders;

--b. What percentage of revenues comes from which type of paper? Provide a
--visualization that illustrates the results (e.g. pie chart, bar plot, or any chart
--of your choice)
select round(100*sum(standard_amt_usd)/sum(total_amt_usd),2) as standard_rev_pct,
round(100*sum(gloss_amt_usd)/sum(total_amt_usd),2) as gloss_rev_pct,
round(100*sum(poster_amt_usd)/sum(total_amt_usd),2) as poster_rev_pct
from orders;

-- 4. Is the business growing?
-- a. How have revenues been year over year? For this, only take into account years with full data 
-- (2017 just started, so we don’t know how yearly revenues will be and 2013 seems to have data only from December).
-- Provide a visualization that illustrates the results (e.g. line chart, bar plot, or any chart of your choice). (1.5 point)
select extract(year from occurred_at) as year, sum(total_amt_usd) total_revenue
from orders 
where extract(year from occurred_at) in (select extract(year from occurred_at) as year from orders
										 group by year
										 having count(distinct(extract(month from occurred_at)))=12)
group by year
order by year;

-- b. How have units sold evolved year over year? Here too, only take into account the past years’ data. 
-- Provide a visualization that illustrates the results (e.g. line chart, bar plot, or any chart of your choice) (1.5 point)
select extract(year from occurred_at) as year, sum(standard_qty) standard_qty_total, sum(gloss_qty) gloss_qty_total, sum(poster_qty) poster_qty_total,sum(total) total_qty_sold 
from orders 
where extract(year from occurred_at) in (select extract(year from occurred_at) as year from orders
										 group by year
										 having count(distinct(extract(month from occurred_at)))=12)
group by year
order by year;

-- 5. How many sales reps do they have in each region? 
-- Sort the result by alphabetical order and include the regions that do not have any sales reps (1.5 point)
select r.name, count(distinct(sr.id)) from region r
left join sales_reps sr on r.id=sr.region_id
group by r.name
order by r.name;

-- 6. a. From Parch and Posey’s leadership team you know that North,South and International are 3 newly added regions.
-- If Dunder Mifflin decided to buy Parch and Posey, they would need to jump start sales in those areas. 
-- How would you suggest reallocating sales reps from the old to the new regions to cover the needs of the latter,
-- i.e. which old regions would you recommend to pull sales reps from?
select r.name, count(distinct o.id) as Total_Orders,
count(distinct sr.id) as Total_Reps, count(distinct a.id) as Total_Accounts, sum(o.total_amt_usd) as Total_Rev, avg(o.total_amt_usd) as Average_Rev from region r
right join sales_reps sr on r.id=sr.region_id
right join accounts a on a.sales_rep_id=sr.id
full join orders o on o.account_id=a.id
where extract (year from o.occurred_at) = '2016'
group by r.name; 

-- b. Based on the previous result, compute also by region: number of orders per representative in that region, 
-- number of accounts handled per representative, revenues per representative
select r.name, count(distinct o.id)/count(distinct sales_rep_id) as orders_per_representative,
count (distinct a.id)/count(distinct sales_rep_id) as accounts_per_representative, 
sum(o.total_amt_usd)/count(distinct sales_rep_id) as revenues_per_representative
from region r
right join sales_reps sr on r.id=sr.region_id
right join accounts a on a.sales_rep_id=sr.id full join orders o on o.account_id=a.id
where extract(year from o.occurred_at) = '2016' group by r.name
order by revenues_per_representative ASC;

-- Based on the calculation above, it is evident that the Midwest region is currently underperforming compared to other regions. 
-- To optimize overall sales efficiency and distribution, I recommend a strategic reallocation of sales representatives from the Midwest to other regions.

--7. To answer if this is true, create a new column in your output that is:
--- ‘group’ if the name of the account ends with the word ‘group’-‘not group’ otherwise
-- Then, based on the above result, compute the average (per account) revenues that
-- came respectively from ‘group’ and from ‘not group’ accounts. (Hint: Here we would
-- need 2 numbers, the average revenues for ‘group’ accounts and the average revenues for ‘not group’ accounts).
-- Finally, comment on the result and on whether your assumption was correct. (2 points)
select gt.group_type, avg(total_revenue) avg_total_revenue
from (select o.account_id, sum(o.total_amt_usd) total_revenue
	  from orders o
	  group by o.account_id order by total_revenue) tr
left join (select a.id,
		   case 
		   	when lower(right(a.name,5)) = 'group' then 'group'
		   	else 'not_group'
		   end group_type
		   from accounts a) as gt on tr.account_id=gt.id
group by gt.group_type;

--select * from orders
--select * from region
--select * from web_events

select id from accounts
where id not in (select distinct(account_id) from orders)