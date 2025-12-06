{{
  config(
    description='User journey with all touchpoints leading to conversion',
    materialized='table'
  )
}}

WITH conversions AS (
  SELECT
    user_pseudo_id,
    event_timestamp AS conversion_timestamp,
    event_id AS conversion_event_id
  FROM {{ ref('stg_ga4_events') }}
  WHERE event_name = 'purchase'
),

user_events_before_conversion AS (
  SELECT
    c.user_pseudo_id,
    c.conversion_timestamp,
    c.conversion_event_id,
    e.event_id,
    e.event_timestamp,
    e.event_name,
    e.traffic_source,
    e.traffic_medium,
    ROW_NUMBER() OVER (
      PARTITION BY c.user_pseudo_id, c.conversion_timestamp 
      ORDER BY e.event_timestamp ASC
    ) AS touchpoint_number,
    ROW_NUMBER() OVER (
      PARTITION BY c.user_pseudo_id, c.conversion_timestamp 
      ORDER BY e.event_timestamp DESC
    ) AS reverse_touchpoint_number
  FROM conversions c
  INNER JOIN {{ ref('stg_ga4_events') }} e
    ON c.user_pseudo_id = e.user_pseudo_id
    AND e.event_timestamp <= c.conversion_timestamp
    AND e.event_timestamp >= TIMESTAMP_SUB(c.conversion_timestamp, INTERVAL {{ var('lookback_days') }} DAY)
)

SELECT
  user_pseudo_id,
  conversion_timestamp,
  conversion_event_id,
  event_id AS touchpoint_event_id,
  event_timestamp AS touchpoint_timestamp,
  event_name AS touchpoint_event_name,
  traffic_source AS touchpoint_source,
  traffic_medium AS touchpoint_medium,
  touchpoint_number,
  reverse_touchpoint_number,
  CASE WHEN touchpoint_number = 1 THEN TRUE ELSE FALSE END AS is_first_touch,
  CASE WHEN reverse_touchpoint_number = 1 THEN TRUE ELSE FALSE END AS is_last_touch,
  CURRENT_TIMESTAMP() AS _loaded_at
FROM user_events_before_conversion
