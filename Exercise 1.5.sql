--Goal: Count and return the net users added each day, accounting for new, deleted, and merged users
--Data source: Data is available by default on app.mode.com, where this was created
--Data visualization provided in Exercise_1-5.pdf in the same folder this file is in

--Step 1: Get a total user count
SELECT 
  count(users) AS user_count
FROM 
  dsv1069.users;

--Step 2: Count daily new users 
SELECT
  date(created_at) AS day,
  COUNT(*) AS new_users_added
FROM
  dsv1069.users
GROUP BY 
  date(created_at);

--Step 3: Count deleted users by day
SELECT
  date(deleted_at) AS day,
  COUNT(*) AS deleted_users
FROM
  dsv1069.users
WHERE
  deleted_at IS NOT NULL
GROUP BY 
  date(deleted_at);

--Step 4: Count merged users by day
SELECT 
  date(merged_at) AS day,
  COUNT(*) AS merged_users
FROM 
  dsv1069.users
WHERE 
  id <> parent_user_id
AND 
  parent_user_id IS NOT NULL 
GROUP BY 
  date(merged_at);

--Step 5: Combine steps 2-4 and calculate a new net users added field
SELECT 
  DATE(new.day),
  (COALESCE(new.new_users_added,0) - COALESCE(deleted.deleted_users,0) - COALESCE(merged.merged_users,0)) 
    AS net_added_users,
  COALESCE(new.new_users_added,0) AS new_users_added,
  COALESCE(deleted.deleted_users,0) AS deleted_users,
  COALESCE(merged.merged_users,0) AS merged_users
FROM
  (SELECT
    date(created_at) AS day,
    COUNT(*) AS new_users_added
  FROM
    dsv1069.users
  GROUP BY 
    date(created_at)
  ) new
LEFT OUTER JOIN 
  (SELECT
    date(deleted_at) AS day,
    COUNT(*) AS deleted_users
  FROM
    dsv1069.users
  WHERE
    deleted_at IS NOT NULL
  GROUP BY 
    date(deleted_at)
  ) deleted
ON 
  deleted.day = new.day 
LEFT OUTER JOIN 
  (SELECT 
    date(merged_at) AS day,
    COUNT(*) AS merged_users
  FROM 
    dsv1069.users
  WHERE 
    id <> parent_user_id
  AND 
    parent_user_id IS NOT NULL 
  GROUP BY 
    date(merged_at)
  ) merged
ON 
  merged.day = new.day ;
