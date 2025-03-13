--[Mode](https://app.mode.com/) is the only data source used for this project.

--Goal:
--Exercise 1: Create subtable for recently viewed events using view_item_events table

SELECT 
  user_id,
  item_id,
  event_time,
  ROW_NUMBER() OVER (
    PARTITION BY user_id 
    ORDER BY event_time 
    DESC
  ) AS view_number
FROM 
  dsv1069.view_item_events;



--GOAL:
--Exercise 2: Join tables recent_views (created in exercise 1), users, and items
--Exercise 3: Clean up columns

SELECT 
  users.id               AS user_id,
  users.email_address    AS user_email,
  items.id               AS item_id,
  items.name             AS item_name,
  items.category         AS item_category
FROM 
  (SELECT 
    view_item_events.user_id,
    view_item_events.item_id,
    view_item_events.event_time,
    ROW_NUMBER() OVER (
      PARTITION BY view_item_events.user_id 
      ORDER BY view_item_events.event_time DESC
    ) AS view_number
  FROM 
    dsv1069.view_item_events
  ) recent_views

JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id 

JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id;



--Goal:
--Exercise 4: Filtering users to better target promo emails

SELECT 
  COALESCE(users.parent_user_id, users.id)    AS user_id,
  users.email_address                         AS user_email,
  items.id                                    AS item_id,
  items.name                                  AS item_name,
  items.category                              AS item_category,
  date(recent_views.event_time)               AS date_viewed
FROM 
  (SELECT 
    view_item_events.user_id,
    view_item_events.item_id,
    view_item_events.event_time,
    ROW_NUMBER() OVER (
      PARTITION BY view_item_events.user_id 
      ORDER BY view_item_events.event_time DESC
    ) AS view_number
  FROM 
    dsv1069.view_item_events
  WHERE event_time >= '2017-01-01'            --Note: data only runs through 2018
  ) recent_views

JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id 

JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id
  
LEFT OUTER JOIN
  dsv1069.orders 
ON 
  orders.item_id = recent_views.item_id 
  AND orders.user_id = recent_views.user_id

WHERE 
  view_number = 1
  AND users.deleted_at IS NULL;
