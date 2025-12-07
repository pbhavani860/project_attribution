# Project Attribution

Multi-touch attribution analytics for Google Analytics 4 ecommerce data using dbt, BigQuery, and Python.

## Overview

Built end-to-end attribution analytics pipeline using dbt and BigQuery to analyze 1,204 conversions from 300K+ GA4 events. Implemented first-click and last-click attribution models to identify which marketing channels initiate customer journeys versus which ones close sales. Created 7 tested dbt models, Python real-time streaming script, and 6-chart interactive dashboard. Key finding: Referral traffic is 109% more effective at closing conversions (165 vs 79), revealing it's undervalued in traditional first-click attribution models.
## Architecture
<img width="669" height="428" alt="Screenshot 2025-12-07 120002" src="https://github.com/user-attachments/assets/00e8feae-64d4-4347-a647-1aa5238bd5ed" />

```
GA4 Public Dataset (events_*)
        |
        v
STAGING (VIEW)
  - stg_ga4_events
        |
        v
INTERMEDIATE (TABLE)
  - int_sessions
  - int_user_journey
        |
        v
MARTS (TABLE)
  - fct_first_click
  - fct_last_click
  - mart_attr_summary

Real-time Streaming:
Python Streaming Script -> raw_streaming.events_stream
```
##  Quick Stats

- **Conversions Analyzed**: 1,204
- **Events Processed**: 300,000+
- **Channel Combinations**: 18
- **Data Quality Tests**: 15+ (100% passing)
- **Dashboard Charts**: 6 interactive visualizations
- **Development Time**: 7 hours

##  Tech Stack

- **dbt 1.10+**: Data transformation
- **BigQuery**: Cloud data warehouse
- **Python 3.8+**: Real-time streaming
- **Looker Studio**: Interactive dashboards
- **SQL**: Advanced window functions & CTEs

## Installation

Clone repository
```
git clone https://github.com/pbhavani860/project_attribution.git
cd project_attribution
```

Create virtual environment
```
python -m venv .venv
```

Activate
```
.venv\Scripts\activate 
```

Install dependencies
```
pip install -r requirements.txt
```

Run dbt models
```
cd ProjectAttribution
dbt debug
dbt run
dbt test
```
