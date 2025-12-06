{{
  config(
    description='User sessions with 30-minute inactivity timeout',
    materialized='table'
  )
}}

WITH events_with_previous AS (
  SELECT
    event_id,
    event_timestamp,
    event_date,
    event_name,
    user_pseudo_id,
    traffic_medium,
    traffic_source,
    TIMESTAMP_DIFF(
      event_timestamp,
      LAG(event_timestamp) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp),
      MINUTE
    ) AS minutes_since_last_event
  FROM {{ ref('stg_ga4_events') }}
),

sessions_identified AS (
  SELECT
    *,
    SUM(CASE WHEN minutes_since_last_event > 30 OR minutes_since_last_event IS NULL THEN 1 ELSE 0 END) 
      OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS session_number
  FROM events_with_previous
),

sessions_aggregated AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(session_number AS STRING)) AS session_id,
    user_pseudo_id,
    MIN(event_timestamp) AS session_start_time,
    MAX(event_timestamp) AS session_end_time,
    COUNT(DISTINCT event_id) AS event_count,
    COUNT(DISTINCT CASE WHEN event_name = 'page_view' THEN event_id END) AS page_views,
    MAX(CASE WHEN session_number = 1 THEN traffic_source END) AS first_traffic_source,
    MAX(CASE WHEN session_number = 1 THEN traffic_medium END) AS first_traffic_medium,
    TIMESTAMP_DIFF(MAX(event_timestamp), MIN(event_timestamp), SECOND) AS session_duration_seconds
  FROM sessions_identified
  GROUP BY session_id, user_pseudo_id
)

SELECT
  session_id,
  user_pseudo_id,
  session_start_time,
  session_end_time,
  event_count,
  page_views,
  first_traffic_source,
  first_traffic_medium,
  session_duration_seconds,
  CURRENT_TIMESTAMP() AS _loaded_at
FROM sessions_aggregated
