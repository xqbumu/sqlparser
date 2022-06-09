WITH users AS (
  SELECT id AS user_id,
    username,
    created_at
  FROM tbl_users
  WHERE id < 100
),
events AS (
  SELECT user_id,
    created_at AS event_at
  FROM tbl_events
  WHERE id IN (
      SELECT id
      FROM users
    )
),
orders AS (
  SELECT u.user_id,
    amount
  FROM tbl_orders o
    JOIN users u ON u.user_id = o.user_id
)
SELECT u.user_id AS user_id,
  COUNT(l.event_at) AS event_cnt,
  MAX(event_at) AS last_event_at,
  COUNT(DISTINCT CAST(l.event_at AS Date)) AS event_days
FROM events l
  JOIN users u ON u.user_id = l.user_id
GROUP BY u.user_id