# Assumptions & Design Decisions


## Day 1: Staging Layer


### Data Source

- Using GA4 public sample dataset (e-commerce)

- Sample data from January 2021 (events_20210101 to events_20210131)

- Date-partitioned tables for query efficiency

- Public dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce



### Identity Resolution

- Primary identifier: user_pseudo_id (GA4 native)

- No cross-device stitching implemented

- No user ID mapping (privacy-first approach)

- Each user tracked by single pseudo ID



### Data Quality

- Required fields: user_pseudo_id, event_timestamp, event_name must not be null

- Tests: not_null on key fields, unique on event_id

- Generated UUID for event_id to ensure uniqueness across all events

- Null handling: Default values for missing traffic sources



### Traffic Source Handling

- Medium defaults to '(none)' when null

- Source defaults to 'direct' when null

- Preserves GA4 standard naming conventions

- <Other> represents aggregated long-tail sources



### Performance Optimization

- Staging model: Materialized as VIEW (always fresh, lightweight)

- Uses _TABLE_SUFFIX for partition pruning (cost optimization)

- Specific date range to control query costs

- No bot filtering applied (sample data assumption)


## Day 2: Intermediate & Attribution Models

### Session Logic

- 30-minute inactivity timeout (industry standard)

- Session boundaries defined by time gaps between events

- First traffic source captured at session start

- Session duration calculated from first to last event


### Attribution Window

- 30-day lookback before each conversion

- Conversion event: event_name = 'purchase'

- All touchpoints within window included in journey

- No cross-session attribution limits


### Attribution Models

- **First-click**: 100% credit to first touchpoint in journey

- **Last-click**: 100% credit to last touchpoint before purchase

- No multi-touch distribution (future enhancement)

- Equal credit (1.0) assigned to winning touchpoint


### Data Filtering

- Only users with purchase events included in attribution

- All touchpoints must have valid traffic source/medium

- Events outside 30-day window excluded

- Conversion timestamp used as anchor point


### Materialization Strategy

- Intermediate models: Materialized as TABLES (better join performance)

- Attribution models: Materialized as TABLES (reporting layer)

- Summary marts: Pre-aggregated for fast dashboard queries

- Staging: VIEW for always-fresh source data



## Attribution Insights (Observed)


### Overall Metrics

- 1,204 total conversions tracked

- 18 unique source/medium combinations

- Average touchpoints per conversion: ~20-50


### Channel Performance


- First-click: 364 conversions (30%)

- Last-click: 310 conversions (26%)

- Insight: Strong at both initiating and closing



- **Direct traffic**: Brand strength indicator

- First-click: 299 conversions (25%)

- Last-click: 269 conversions (22%)



## Known Limitations


### Data Constraints

- Sample dataset only (not production data)

- Limited to January 2021 events

- Obfuscated data (privacy protection)

- No real-time updates (historical data)




### Technical Limitations

- No cross-device user stitching

- No offline conversion tracking

- No revenue/value attribution

- No assisted conversion metrics

- No path frequency analysis

## day 3 : Dashboard in Looker

### Real-Time Streaming

- Python script for live event ingestion

- Streaming to BigQuery in real-time

- Dashboard updates with fresh data

- Connected Looker Studio to BigQuery
- Created 6 visualizations:
  1. Model comparison bar chart
  2. Channel performance table
  3. Scorecards (first vs last)
  4. Source distribution pie chart
  5. Advanced grouped bar chart
  6. Conversion rate line chart (calculated field)
- Added interactive filters
- Made dashboard mobile-responsive






