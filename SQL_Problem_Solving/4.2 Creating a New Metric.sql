--Final table from Exercise 4.1 Test Assignments

SELECT 
  user_id,
  test_id,
  date(event_time) AS assignment_date,
  COUNT(DISTINCT test_assignment) AS assignments
FROM 
  (SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE 
      WHEN parameter_name = 'test_id'
      THEN CAST(parameter_value AS INT)
      ELSE NULL 
      END) AS test_id,
    MAX(CASE 
      WHEN parameter_name = 'test_assignment'
      THEN parameter_value
      ELSE NULL 
    END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY 
    event_id,
    event_time,
    user_id,
    platform
  ORDER BY 
    event_id
  ) test_events
GROUP BY 
  user_id,
  test_id,
  event_time
ORDER BY 
  COUNT(DISTINCT test_assignment) DESC;




--Goal: Use the Test Assignments table to measure 
--whether a user created an order after their test assignment.
--Be sure to include only users assigned to the test, even 
--if they have zero orders after test assignment.

SELECT 
  test_events.user_id,
  test_events.test_id,
  test_events.test_assignment,
  COUNT(DISTINCT (CASE 
    WHEN orders.created_at > test_events.event_time 
    THEN orders.invoice_id 
    ELSE NULL 
  END)) AS orders_after_assignment
FROM 
  (SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE 
      WHEN parameter_name = 'test_id'
      THEN CAST(parameter_value AS INT)
      ELSE NULL 
      END) AS test_id,
    MAX(CASE 
      WHEN parameter_name = 'test_assignment'
      THEN parameter_value
      ELSE NULL 
    END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY 
    event_id,
    event_time,
    user_id,
    platform
  ) test_events
LEFT OUTER JOIN 
  dsv1069.orders
ON 
  orders.user_id = test_events.user_id
GROUP BY 
  test_events.user_id,
  test_events.test_id,
  test_events.test_assignment;




--Goal: Add number of invoices, number of line_items, 
--and total revenue from users after test_assignment

--Note: Number of invoices is already included as orders_after_assignment

SELECT 
  test_events.user_id,
  test_events.test_id,
  test_events.test_assignment,
  COUNT(DISTINCT (CASE 
    WHEN orders.created_at > test_events.event_time 
    THEN orders.invoice_id 
    ELSE NULL 
  END)) AS orders_after_assignment,
  COUNT(DISTINCT (CASE 
    WHEN orders.created_at > test_events.event_time 
    THEN orders.line_item_id 
    ELSE NULL 
  END)) AS line_items_after_assignment,
  SUM(CASE 
    WHEN orders.created_at > test_events.event_time 
    THEN orders.price 
    ELSE 0 
  END) AS revenue_after_assignment
FROM 
  (SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE 
      WHEN parameter_name = 'test_id'
      THEN CAST(parameter_value AS INT)
      ELSE NULL 
      END) AS test_id,
    MAX(CASE 
      WHEN parameter_name = 'test_assignment'
      THEN parameter_value
      ELSE NULL 
    END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY 
    event_id,
    event_time,
    user_id,
    platform
  ) test_events
LEFT OUTER JOIN 
  dsv1069.orders
ON 
  orders.user_id = test_events.user_id
GROUP BY 
  test_events.user_id,
  test_events.test_id,
  test_events.test_assignment;
