--Goal: Find how many tests are in the data

SELECT 
  DISTINCT parameter_value AS test_id
FROM 
  dsv1069.events 
WHERE 
  event_name = 'test_assignment'
  AND parameter_name = 'test_id';

--Result: There are 4 tests in this data set




--Goal: Write a query that returns a table of assignment events.
--Please include all of the relevant parameters as columns

SELECT 
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
  event_id;




--Goal: Check whether users are assigned to only 1 treatment group for a given test_id

SELECT 
  user_id,
  test_id,
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
  test_id
ORDER BY 
  COUNT(DISTINCT test_assignment) DESC;
  
--No users have been assigned to multiple treatment groups for any single test_id
