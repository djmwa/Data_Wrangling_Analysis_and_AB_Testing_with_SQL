--Goal:
--Exercise 1: Find out how many users have ever ordered

SELECT
  COUNT(DISTINCT users.id) AS users_with_orders
FROM 
  dsv1069.users
INNER JOIN 
  dsv1069.orders 
ON 
  orders.user_id = users.id;

--Result: 17,463




--Goal:
--Exercise 2: How many users have reordered the same item?

SELECT 
  COUNT(DISTINCT user_id) AS users_with_reorders
FROM 
  (SELECT
    user_id,
    item_id,
    COUNT(DISTINCT line_item_id) AS times_user_ordered
  FROM 
    dsv1069.orders 
  GROUP BY 
    user_id,
    item_id
  ) user_level_orders
WHERE
  times_user_ordered > 1;

--Result: 211




--Goal:
--Exercise 3: Only 211 users reordered an item out of 17,463 users with orders.
--How many users have multiple orders, regardless of item?

SELECT 
  COUNT(*) AS users_with_multiple_orders
FROM 
  (SELECT 
    user_id,
    COUNT(DISTINCT invoice_id) AS order_count
  FROM 
    dsv1069.orders
  GROUP BY 
    user_id
  ) user_orders
WHERE
  order_count > 1;

--Result: 1,421




--Goal:
--Exercise 4: Only 1,421 of 17,463 users have placed more than a single user.
--EXPLORATORY question: Do users order multiple items with a shared category?
-- Does that differ between categories?

SELECT 
  item_category,
  AVG(times_category_ordered) AS avg_times_category_ordered
FROM 
  (SELECT 
    user_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS times_category_ordered
  FROM 
    dsv1069.orders 
  GROUP BY 
    user_id,
    item_category
  ) user_level
GROUP BY 
  item_category
ORDER BY 
  AVG(times_category_ordered) DESC;

--Results: Minimal difference between categories, average items ordered per category
--range from 2.3395 to 2.4122.



--Goal:
--Exercise 7: Find average time between orders

SELECT 
  AVG( (date(second_orders.paid_at) - date(first_orders.paid_at)) ) AS avg_date_diff
FROM 
  (SELECT 
    DISTINCT user_id AS user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (
      PARTITION BY user_id
      ORDER BY paid_at ASC 
    ) AS order_num
  FROM 
    dsv1069.orders
  ) first_orders
JOIN 
  (SELECT 
    DISTINCT user_id AS user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (
      PARTITION BY user_id
      ORDER BY paid_at ASC 
    ) AS order_num
  FROM 
    dsv1069.orders
  ) second_orders
ON 
  first_orders.user_id = second_orders.user_id 
WHERE 
  first_orders.order_num = 1
  AND second_orders.order_num = 2;

--Result: Average of 66 days between first and second orders.
