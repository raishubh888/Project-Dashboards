CREATE DATABASE project;
USE project;


# SQL PROJECT ON GLOBAL EV DATA


DESCRIBE global_ev;

SELECT * FROM global_ev;

# Q1) What is the total EV stock for each region?

SELECT region, SUM(value) AS total_ev_stock
FROM global_ev
WHERE parameter = 'EV stock'
GROUP BY region
ORDER BY total_ev_stock DESC;

# Q2) Which year had the highest total EV sales?

SELECT year, SUM(value) AS total_ev_sales
FROM global_ev
WHERE parameter = 'EV sales'
GROUP BY year
ORDER BY total_ev_sales DESC
LIMIT 1;

# Q3) What is the average EV stock share percentage across all regions and years?

SELECT AVG(value) AS avg_ev_stock_share
FROM global_ev
WHERE parameter = 'EV stock share' AND unit = 'percent';

# Q4) Find the region with the highest average EV sales share in percentage over all years.

SELECT region, AVG(value) AS avg_ev_sales_share
FROM global_ev
WHERE parameter = 'EV sales share' AND unit = 'percent'
GROUP BY region
ORDER BY avg_ev_sales_share DESC
LIMIT 1;

# Q5) What is the total number of EVs for each powertrain type?

SELECT powertrain, SUM(value) AS total_ev
FROM global_ev
WHERE parameter = 'EV stock'
GROUP BY powertrain
ORDER BY total_ev DESC;

# Q6) What is the total EV stock by mode (e.g., Cars, Trucks) across all years?

SELECT mode, SUM(value) AS total_ev_stock
FROM global_ev
WHERE parameter = 'EV stock'
GROUP BY mode
ORDER BY total_ev_stock DESC;

# Q7) Rank the powertrain types by total EV stock in 2023 within each region.

SELECT region, powertrain, SUM(value) AS total_ev_stock,
RANK() OVER (PARTITION BY region ORDER BY SUM(value) DESC) AS powertrain_rank
FROM global_ev
WHERE parameter = 'EV stock' AND year = 2023
GROUP BY region, powertrain
ORDER BY region, powertrain_rank;

# Q8) What is the EV sales share percentage by region, ranked by highest to lowest, for each year?

SELECT year, region, value AS ev_sales_share,
RANK() OVER (PARTITION BY year ORDER BY value DESC) AS share_rank
FROM global_ev
WHERE parameter = 'EV sales share' AND unit = 'percent'
ORDER BY year, share_rank;

# Q9) Identify the regions where the EV stock doubled from one year to the next.

SELECT EV1.region, EV1.year, EV1.value AS current_stock, EV2.value AS previous_stock
FROM global_ev EV1
JOIN global_ev EV2 
    ON EV1.region = EV2.region
    AND EV1.parameter = EV2.parameter
    AND EV1.year = EV2.year + 1
WHERE EV1.parameter = 'EV stock'
  AND EV1.value >= 2 * EV2.value
ORDER BY EV1.region, EV1.year;

# Q10) Compare EV sales share between consecutive years within each region and mode (e.g., Cars, Trucks).

SELECT E1.region, E1.mode, E1.year, E1.value AS current_sales_share, E2.value AS previous_sales_share,
(E1.value - E2.value) AS sales_share_change
FROM global_ev AS E1
JOIN global_ev AS E2 
ON E1.region = E2.region
AND E1.mode = E2.mode
AND E1.parameter = E2.parameter
AND E1.year = E2.year + 1
WHERE E1.parameter = 'EV sales share'
AND E1.unit = 'percent'
ORDER BY E1.region, E1.mode, E1.year;

USE project;

# SQL PROJECT ON UNICORN_COMPANIES

SELECT * FROM unicorn_companies;

# Q1) List all companies founded after the year 2010.

SELECT Company, Year_Founded
FROM Unicorn_Companies
WHERE Year_Founded > 2010;

# Q2) Find the top 5 companies with the highest valuations.

SELECT Company, Valuation
FROM Unicorn_Companies
ORDER BY Valuation DESC
LIMIT 5;

# Q3) Count the number of unicorn companies in each industry.

SELECT Industry, COUNT(*) AS Company_Count
FROM Unicorn_Companies
GROUP BY Industry
ORDER BY Company_Count DESC;

#Q4) Find the youngest company (based on Year_Founded) with the highest valuation.

SELECT Company, Year_Founded, Valuation
FROM Unicorn_Companies
WHERE Valuation = (SELECT MAX(Valuation) FROM Unicorn_Companies)
ORDER BY Year_Founded DESC
LIMIT 1;

# Q5) Find the Oldest and Newest Year Founded

SELECT MIN(Year_Founded) AS Oldest_Year, MAX(Year_Founded) AS Newest_Year
FROM Unicorn_Companies;

# Q6) Find the rank of companies by valuation within each industry.

SELECT Industry,Company,Valuation,
RANK() OVER (PARTITION BY Industry ORDER BY Valuation DESC) AS Rank_By_Valuation
FROM Unicorn_Companies
ORDER BY Industry, Rank_By_Valuation;

# Q7) Find the dense rank of companies by funding within each continent.

SELECT Continent,Company,Funding,
DENSE_RANK() OVER (PARTITION BY Continent ORDER BY Funding DESC) AS Dense_Rank_By_Funding
FROM Unicorn_Companies
ORDER BY Continent, Dense_Rank_By_Funding;

# Q8) Assign a unique row number to each company based on valuation globally.

SELECT ROW_NUMBER() OVER (ORDER BY Valuation DESC) AS Row_Num,
Company,Valuation,Industry
FROM Unicorn_Companies
ORDER BY Row_Num;

# Q9) Find the next highest valued company in the same industry.

SELECT Industry,Company,Valuation,
LEAD(Company) OVER (PARTITION BY Industry ORDER BY Valuation DESC) AS Next_Highest_Company,
LEAD(Valuation) OVER (PARTITION BY Industry ORDER BY Valuation DESC) AS Next_Highest_Valuation
FROM Unicorn_Companies
ORDER BY Industry, Valuation DESC;

# Q10) Find the previous company in terms of valuation in the same country.

SELECT Country,Company,Valuation,
LAG(Company) OVER (PARTITION BY Country ORDER BY Valuation DESC) AS Previous_Company,
LAG(Valuation) OVER (PARTITION BY Country ORDER BY Valuation DESC) AS Previous_Valuation
FROM Unicorn_Companies
ORDER BY Country, Valuation DESC;

USE project;


# SQL PROJECT ON Burgetto's sales

SELECT * FROM burger;

# 1) Total Revenue:

SELECT SUM(total_price) AS Total_Revenue FROM burger;

# 2) Average Order Value

SELECT (SUM(total_price) / COUNT(DISTINCT order_id)) 
AS Avg_order_Value FROM burger;

# 3) Total item Sold

SELECT SUM(quantity) AS Total_item_sold FROM burger;

# 4) Total Orders

SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM burger;

# 5) Average item Per Order

SELECT ROUND(SUM(quantity)/ COUNT(DISTINCT order_id), 2) 
AS Avg_items_per_orde FROM burger;

# 6) % of Sales by item Category

SELECT item_category, 
SUM(total_price) AS total_revenue,
ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM burger), 2) AS PCTR     # PCTR:- Percentage contribution to total_revenue
FROM burger                                                                              #    by each item_category
GROUP BY item_category;

# 7) % of Sales by item Size

SELECT item_size, 
SUM(total_price) AS total_revenue,
ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM burger), 2) AS PCTR
FROM burger
GROUP BY item_size
ORDER BY item_size;

# 8) Top 5 items by Revenue

SELECT item_name, SUM(total_price) AS Total_Revenue
FROM burger
GROUP BY item_name
ORDER BY Total_Revenue DESC
LIMIT 5;

# 9) Bottom 5 items by Revenue

SELECT item_name, SUM(total_price) AS Total_Revenue
FROM burger
GROUP BY item_name
ORDER BY Total_Revenue ASC
LIMIT 5;

# 10) Top 5 items by Quantity

SELECT item_name, SUM(Quantity) AS Total_item_sold
FROM burger
GROUP BY item_name
ORDER BY Total_item_sold DESC
LIMIT 5;

# 11) Bottom 5 items by Quantity

SELECT item_name, SUM(Quantity) AS Total_item_sold
FROM burger
GROUP BY item_name
ORDER BY Total_item_sold ASC
LIMIT 5;

# 12) Top 5 items by Total Orders

SELECT item_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM burger
GROUP BY item_name
ORDER BY Total_Orders DESC
LIMIT 5;

# 13) Bottom 5 items by Total Orders

SELECT item_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM burger
GROUP BY item_name
ORDER BY Total_Orders ASC
LIMIT 5;


SHOW TABLES;