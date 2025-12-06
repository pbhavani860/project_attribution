\# Assumptions \& Design Decisions



\## Day 1: Staging Layer



\### Data Source

\- Using GA4 public sample dataset (e-commerce)

\- Sample data from January 2021 (events\_20210101 to events\_20210131)

\- Date-partitioned tables for query efficiency

\- Public dataset: bigquery-public-data.ga4\_obfuscated\_sample\_ecommerce



\### Identity Resolution

\- Primary identifier: user\_pseudo\_id (GA4 native)

\- No cross-device stitching implemented

\- No user ID mapping (privacy-first approach)

\- Each user tracked by single pseudo ID



\### Data Quality

\- Required fields: user\_pseudo\_id, event\_timestamp, event\_name must not be null

\- Tests: not\_null on key fields, unique on event\_id

\- Generated UUID for event\_id to ensure uniqueness across all events

\- Null handling: Default values for missing traffic sources



\### Traffic Source Handling

\- Medium defaults to '(none)' when null

\- Source defaults to 'direct' when null

\- Preserves GA4 standard naming conventions

\- <Other> represents aggregated long-tail sources



\### Performance Optimization

\- Staging model: Materialized as VIEW (always fresh, lightweight)

\- Uses \_TABLE\_SUFFIX for partition pruning (cost optimization)

\- Specific date range to control query costs

\- No bot filtering applied (sample data assumption)



---



\## Day 2: Intermediate \& Attribution Models



\### Session Logic

\- 30-minute inactivity timeout (industry standard)

\- Session boundaries defined by time gaps between events

\- First traffic source captured at session start

\- Session duration calculated from first to last event



\### Attribution Window

\- 30-day lookback before each conversion

\- Conversion event: event\_name = 'purchase'

\- All touchpoints within window included in journey

\- No cross-session attribution limits



\### Attribution Models

\- \*\*First-click\*\*: 100% credit to first touchpoint in journey

\- \*\*Last-click\*\*: 100% credit to last touchpoint before purchase

\- No multi-touch distribution (future enhancement)

\- Equal credit (1.0) assigned to winning touchpoint



\### Data Filtering

\- Only users with purchase events included in attribution

\- All touchpoints must have valid traffic source/medium

\- Events outside 30-day window excluded

\- Conversion timestamp used as anchor point



\### Materialization Strategy

\- Intermediate models: Materialized as TABLES (better join performance)

\- Attribution models: Materialized as TABLES (reporting layer)

\- Summary marts: Pre-aggregated for fast dashboard queries

\- Staging: VIEW for always-fresh source data



---



\## Attribution Insights (Observed)



\### Overall Metrics

\- 1,204 total conversions tracked

\- 18 unique source/medium combinations

\- Average touchpoints per conversion: ~20-50



\### Channel Performance

\- \*\*Google organic\*\*: Strongest in both models

&nbsp; - First-click: 364 conversions (30%)

&nbsp; - Last-click: 310 conversions (26%)

&nbsp; - Insight: Strong at both initiating and closing



\- \*\*Direct traffic\*\*: Brand strength indicator

&nbsp; - First-click: 299 conversions (25%)

&nbsp; - Last-click: 269 conversions (22%)

&nbsp; - Insight: Users already aware of brand



\- \*\*Referral traffic\*\*: Better closer than initiator

&nbsp; - First-click: 79 conversions (shop.googlemerchandisestore.com)

&nbsp; - Last-click: 165 conversions (+109% increase!)

&nbsp; - Insight: Users return via referral to complete purchase



\- \*\*Paid search (CPC)\*\*: Consistent role

&nbsp; - First-click: 51 conversions

&nbsp; - Last-click: 38 conversions

&nbsp; - Insight: Slightly better at initiating than closing



\### Marketing Implications

\- Google organic drives both awareness and conversions

\- Referral traffic undervalued in first-click models

\- Direct traffic indicates strong brand recall

\- Multi-touch attribution would provide fuller picture



---



\## Known Limitations



\### Data Constraints

\- Sample dataset only (not production data)

\- Limited to January 2021 events

\- Obfuscated data (privacy protection)

\- No real-time updates (historical data)



\### Attribution Logic

\- No bot/spam filtering applied

\- No cross-domain tracking implemented

\- No custom channel groupings

\- Simple attribution models only (first/last)

\- No time decay or position-based models



\### Technical Limitations

\- No cross-device user stitching

\- No offline conversion tracking

\- No revenue/value attribution

\- No assisted conversion metrics

\- No path frequency analysis



---



\## Future Enhancements (Day 3)



\### Real-Time Streaming

\- Python script for live event ingestion

\- Streaming to BigQuery in real-time

\- Dashboard updates with fresh data



\### Advanced Attribution

\- Time decay models (closer events weighted more)

\- Position-based models (40-20-40 split)

\- Linear attribution (equal credit to all touchpoints)

\- Custom attribution rules



\### Analytics

\- Conversion funnel analysis

\- User cohort tracking

\- Revenue attribution

\- Customer lifetime value

\- Path analysis (common journey patterns)



