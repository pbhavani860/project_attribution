{{
  config(
    description='Cleaned GA4 events from public dataset',
    materialized='view'
  )
}}

SELECT
  GENERATE_UUID() as event_id,
  TIMESTAMP_MICROS(event_timestamp) as event_timestamp,
  event_date,
  event_name,
  user_pseudo_id,
  COALESCE(traffic_source.medium, '(none)') as traffic_medium,
  COALESCE(traffic_source.source, 'direct') as traffic_source,
  CURRENT_TIMESTAMP() as _loaded_at
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
WHERE
  user_pseudo_id IS NOT NULL
  AND event_timestamp IS NOT NULL
LIMIT 10000
