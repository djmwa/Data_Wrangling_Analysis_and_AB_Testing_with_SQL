--[Mode](https://app.mode.com/) is the only data source used for this project.

--Goal:
-- Exercise 1: Create a subtable of orders per day.

SELECT 
  date(paid_at) AS date_of_order,
  COUNT(DISTINCT invoice_id) AS orders_placed,
  COUNT(DISTINCT line_item_id) AS line_items
FROM 
  dsv1069.orders
GROUP BY 
  date(paid_at);



--Goals:
--Exercise 2: Join the sub table from the previous exercise to 
--the dates rollup table so we can get a row for every date.
--Exercise 3: Clean up columns to reduce clutter

SELECT
  dates_rollup.date AS date,
  COALESCE(daily_orders.orders_placed, 0) AS orders_placed,
  COALESCE(daily_orders.line_items, 0) AS line_items
FROM 
  dsv1069.dates_rollup
LEFT JOIN 
(
  SELECT 
    date(orders.paid_at) AS date_of_order,
    COUNT(DISTINCT orders.invoice_id) AS orders_placed,
    COUNT(DISTINCT orders.line_item_id) AS line_items
  FROM 
    dsv1069.orders
  GROUP BY 
    date(orders.paid_at)
) daily_orders
ON 
  dates_rollup.date = daily_orders.date_of_order;



--Goals:
--Exercise 4: Create 7-day rolling orders table
--Exercise 5: Clean up columns

SELECT
  dates_rollup.date AS date,
  SUM(COALESCE(daily_orders.orders_placed, 0)) AS rolling_orders_placed,
  SUM(COALESCE(daily_orders.line_items, 0)) AS rolling_line_items
FROM 
  dsv1069.dates_rollup
LEFT JOIN 
(
  SELECT 
    date(orders.paid_at) AS date_of_order,
    COUNT(DISTINCT orders.invoice_id) AS orders_placed,
    COUNT(DISTINCT orders.line_item_id) AS line_items
  FROM 
    dsv1069.orders
  GROUP BY 
    date(orders.paid_at)
) daily_orders
ON 
  dates_rollup.date >= daily_orders.date_of_order
  AND dates_rollup.d7_ago < daily_orders.date_of_order
GROUP BY 
  dates_rollup.date
ORDER BY 
  dates_rollup.date;
