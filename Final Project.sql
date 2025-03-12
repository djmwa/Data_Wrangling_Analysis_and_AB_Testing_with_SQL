--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?
--  No, this table does not have all of the data required to compute a 30-day view-binary. Specifically, we will need to know the dates of the tests and the orders so we can createa 30-day window.

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa;




--Reformat the final_assignments_qa to look like the final_assignments
-- table, filling in any missing values with a placeholder of the 
--appropriate data type.

SELECT 
  item_id,
  test_a AS test_assignment,
  (CASE 
    WHEN test_a is NOT NULL 
    THEN 'test_a' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_a is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
  item_id,
  test_b AS test_assignment,
  (CASE 
    WHEN test_b is NOT NULL 
    THEN 'test_b' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_b is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
  item_id,
  test_c AS test_assignment,
  (CASE 
    WHEN test_c is NOT NULL 
    THEN 'test_c' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_c is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
  item_id,
  test_d AS test_assignment,
  (CASE 
    WHEN test_d is NOT NULL 
    THEN 'test_d' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_d is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
  item_id,
  test_e AS test_assignment,
  (CASE 
    WHEN test_e is NOT NULL 
    THEN 'test_e' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_e is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
  item_id,
  test_f AS test_assignment,
  (CASE 
    WHEN test_f is NOT NULL 
    THEN 'test_f' 
    ELSE NULL 
  END) AS test_number,
  (CASE 
    WHEN test_f is NOT NULL 
    THEN '2025-01-01 00:00:00' 
    ELSE NULL 
  END) AS test_start_date
FROM dsv1069.final_assignments_qa;




-- Use this table to compute order_binary for 
-- the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  test_assignment,
  SUM(order_binary) AS ordered_items,
  COUNT(DISTINCT item_id) AS number_of_items
FROM 
  (SELECT 
    item_test_2.item_id,
    item_test_2.test_assignment,
    item_test_2.test_number,
    item_test_2.test_start_date,
    item_test_2.created_at,
    MAX(CASE 
            WHEN (created_at > test_start_date 
            AND DATE_PART('day', created_at - test_start_date) <= 30)
            THEN 1
            ELSE 0
        END) AS order_binary
  FROM
    (
      SELECT
        final_assignments.*,
        DATE(orders.created_at) AS created_at
      FROM
        dsv1069.final_assignments AS final_assignments
      LEFT JOIN 
        dsv1069.orders AS orders 
      ON 
        final_assignments.item_id = orders.item_id
      WHERE
        test_number = 'item_test_2'
    ) AS item_test_2
  GROUP BY 
    item_test_2.item_id,
    item_test_2.test_assignment,
    item_test_2.test_number,
    item_test_2.test_start_date,
    item_test_2.created_at) AS order_binary
GROUP BY 
  test_assignment;




-- Use the final_assignments table to calculate the view binary, and  
-- average views for the 30 day window after the test assignment for 
-- item_test_2. (You may include the day the test started)

SELECT
  test_assignment,
  SUM(binary_view) AS viewed_items,
  COUNT(item_id) AS items_assignment,
  SUM(views) AS total_views,
  SUM(views)/COUNT(item_id) AS average_views
FROM
(
 SELECT 
  final_assignments.test_assignment,
  final_assignments.item_id, 
  MAX(
    CASE 
      WHEN views.event_time > final_assignments.test_start_date 
      THEN 1 
      ELSE 0 
    END)  AS binary_view,
  COUNT(views.event_id) AS views
 FROM 
    dsv1069.final_assignments
 LEFT JOIN 
  (
    SELECT 
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
  ) views
 ON       
  final_assignments.item_id = views.item_id
 AND      
  views.event_time >= final_assignments.test_start_date
 AND      
  DATE_PART('day', views.event_time - final_assignments.test_start_date ) <= 30 
 WHERE    
  final_assignments.test_number = 'item_test_2'
 GROUP BY
  final_assignments.item_id,
  final_assignments.test_assignment
) view_metrics
  
GROUP BY
  view_metrics.test_assignment;
