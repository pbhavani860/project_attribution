{{
  config(
    description='First-click attribution model - credits first touchpoint',
    materialized='table'
  )
}}

WITH first_touch_events AS (
  SELECT
    user_pseudo_id,
    conversion_timestamp,
    conversion_event_id,
    touchpoint_event_id,
    touchpoint_timestamp,
    touchpoint_source,
    touchpoint_medium
  FROM {{ ref('int_user_journey') }}
  WHERE is_first_touch = TRUE
)

SELECT
  GENERATE_UUID() AS attribution_id,
  user_pseudo_id,
  conversion_timestamp,
  conversion_event_id,
  touchpoint_event_id AS attributed_event_id,
  touchpoint_timestamp AS attributed_touchpoint_timestamp,
  touchpoint_source AS attributed_source,
  touchpoint_medium AS attributed_medium,
  'first_click' AS attribution_model,
  1.0 AS attribution_credit,
  CURRENT_TIMESTAMP() AS _loaded_at
FROM first_touch_events
