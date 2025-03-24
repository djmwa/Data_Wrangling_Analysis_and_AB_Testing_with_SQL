--Goal: Count the number of users and count the 
--users with orders for each test_id

SELECT 
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  SUM(orders_after_assignment) AS orders_after_assignment
FROM 
  (SELECT 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment,
    MAX(CASE 
      WHEN orders.created_at > test_events.event_time 
      THEN 1 
      ELSE 0 
    END) AS orders_after_assignment
  FROM 
    (SELECT 
      event_id,
      event_time,
      user_id,
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
      user_id
    ) test_events
  LEFT OUTER JOIN 
    dsv1069.orders
  ON 
    orders.user_id = test_events.user_id
  GROUP BY 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment
  ) order_binary
GROUP BY 
  order_binary.test_id,
  order_binary.test_assignment
ORDER BY 
  test_id,
  test_assignment;




--Goal: Count users with views after test assignment

SELECT 
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  SUM(views_binary) AS views_after_assignment
FROM 
  (SELECT 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment,
    MAX(CASE 
      WHEN date(views.event_time) > test_events.event_time 
      THEN 1 
      ELSE 0 
    END) AS views_binary
  FROM 
    (SELECT 
      event_id,
      event_time,
      user_id,
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
      user_id
    ) test_events
  LEFT OUTER JOIN 
    (SELECT 
      *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    views.user_id = test_events.user_id
  GROUP BY 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment
  ) views_binary
GROUP BY 
  views_binary.test_id,
  views_binary.test_assignment
ORDER BY 
  test_id,
  test_assignment;




--Goal: Count users with views within 30 days after test assignment

SELECT 
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  SUM(views_binary) AS views_after_assignment,
  SUM(views_binary_30d) AS views_within_30d
FROM 
  (SELECT 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment,
    MAX(CASE 
      WHEN date(views.event_time) > test_events.event_time 
      THEN 1 
      ELSE 0 
    END) AS views_binary,
    MAX(CASE 
      WHEN (date(views.event_time) > test_events.event_time 
        AND DATE_PART('day', views.event_time - test_events.event_time) <= 30)
      THEN 1 
      ELSE 0 
    END) AS views_binary_30d
  FROM 
    (SELECT 
      event_id,
      event_time,
      user_id,
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
      user_id
    ) test_events
  LEFT OUTER JOIN 
    (SELECT 
      *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    views.user_id = test_events.user_id
  GROUP BY 
    test_events.user_id,
    test_events.test_id,
    test_events.test_assignment
  ) views_binary
GROUP BY 
  views_binary.test_id,
  views_binary.test_assignment
ORDER BY 
  test_id,
  test_assignment;




--Goal: Return count of users per treatment condition, average number 
--of invoices, and SD of invoices for each test_id

SELECT 
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  AVG(mean_metrics.orders_after_assignment) AS avg_orders,
  STDDEV(mean_metrics.orders_after_assignment) AS stddev_orders
FROM 
  (SELECT 
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
    test_events.test_assignment 
  ) mean_metrics
GROUP BY 
  test_id,
  test_assignment
ORDER BY 
  test_id,
  test_assignment
