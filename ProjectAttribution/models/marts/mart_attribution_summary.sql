{{
  config(
    description='Attribution summary by source and medium',
    materialized='table'
  )
}}

WITH all_attribution AS (
  SELECT * FROM {{ ref('fct_first_click_attribution') }}
  UNION ALL
  SELECT * FROM {{ ref('fct_last_click_attribution') }}
)

SELECT
  attribution_model,
  attributed_source,
  attributed_medium,
  COUNT(DISTINCT conversion_event_id) AS total_conversions,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  SUM(attribution_credit) AS total_attribution_credit,
  MIN(attributed_touchpoint_timestamp) AS earliest_attributed_touchpoint,
  MAX(attributed_touchpoint_timestamp) AS latest_attributed_touchpoint,
  CURRENT_TIMESTAMP() AS _loaded_at
FROM all_attribution
GROUP BY 
  attribution_model,
  attributed_source,
  attributed_medium
ORDER BY 
  attribution_model,
  total_conversions DESC
