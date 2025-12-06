"""
GA4 Event Streaming Script
Simulates real-time event ingestion to BigQuery
"""

import os
import json
import time
import random
from datetime import datetime, timedelta
from google.cloud import bigquery
from google.oauth2 import service_account

# Configuration
PROJECT_ID = "projectattribution-480216"
DATASET_ID = "raw_streaming"
TABLE_ID = "events_stream"
FULL_TABLE_ID = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"

# Event types and sources for simulation
EVENT_TYPES = [
    'page_view', 'session_start', 'user_engagement', 
    'scroll', 'click', 'purchase', 'add_to_cart'
]

TRAFFIC_SOURCES = [
    ('google', 'organic'),
    ('google', 'cpc'),
    ('(direct)', '(none)'),
    ('facebook', 'social'),
    ('shop.googlemerchandisestore.com', 'referral'),
    ('bing', 'organic'),
    ('twitter', 'social'),
]

def get_bigquery_client():
    """Initialize BigQuery client with OAuth"""
    return bigquery.Client(project=PROJECT_ID)

def create_streaming_table():
    """Create BigQuery table for streaming if not exists"""
    client = get_bigquery_client()
    
    # Define table schema
    schema = [
        bigquery.SchemaField("event_id", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("event_timestamp", "TIMESTAMP", mode="REQUIRED"),
        bigquery.SchemaField("event_date", "DATE", mode="REQUIRED"),
        bigquery.SchemaField("event_name", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("user_pseudo_id", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("traffic_source", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("traffic_medium", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("session_id", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("page_location", "STRING", mode="NULLABLE"),
    ]
    
    table = bigquery.Table(FULL_TABLE_ID, schema=schema)
    
    try:
        table = client.create_table(table)
        print(f" Created table {FULL_TABLE_ID}")
    except Exception as e:
        print(f"  Table already exists or error: {e}")
    
    return client

def generate_event():
    """Generate a simulated GA4 event"""
    now = datetime.utcnow()
    source, medium = random.choice(TRAFFIC_SOURCES)
    
    event = {
        "event_id": f"evt_{int(now.timestamp() * 1000000)}_{random.randint(1000, 9999)}",
        "event_timestamp": now.isoformat(),
        "event_date": now.date().isoformat(),
        "event_name": random.choice(EVENT_TYPES),
        "user_pseudo_id": f"user_{random.randint(10000, 99999)}",
        "traffic_source": source,
        "traffic_medium": medium,
        "session_id": f"session_{int(now.timestamp())%100000}",
        "page_location": f"/page{random.randint(1, 10)}",
    }
    
    return event

def stream_events(client, num_events=10, delay=2):
    """Stream events to BigQuery"""
    print(f"\n Starting to stream {num_events} events...")
    print(f" Target: {FULL_TABLE_ID}")
    print(f"  Delay: {delay} seconds between events\n")
    
    errors = []
    
    for i in range(num_events):
        event = generate_event()
        
        # Insert row to BigQuery
        try:
            errors = client.insert_rows_json(FULL_TABLE_ID, [event])
            
            if errors:
                print(f" Error inserting event {i+1}: {errors}")
            else:
                print(f" Event {i+1}/{num_events}: {event['event_name']} | "
                      f"User: {event['user_pseudo_id']} | "
                      f"Source: {event['traffic_source']}/{event['traffic_medium']}")
            
            time.sleep(delay)
            
        except Exception as e:
            print(f" Exception on event {i+1}: {e}")
    
    print(f"\n Streaming complete! {num_events} events sent.")

def verify_data(client):
    """Verify streamed data in BigQuery"""
    query = f"""
    SELECT 
        COUNT(*) as total_events,
        COUNT(DISTINCT user_pseudo_id) as unique_users,
        COUNT(DISTINCT event_name) as unique_event_types,
        MAX(event_timestamp) as latest_event
    FROM `{FULL_TABLE_ID}`
    """
    
    try:
        print("\n Verifying data in BigQuery...")
        results = client.query(query).result()
        
        for row in results:
            print(f"\n Streaming Table Stats:")
            print(f"   Total Events: {row.total_events}")
            print(f"   Unique Users: {row.unique_users}")
            print(f"   Event Types: {row.unique_event_types}")
            print(f"   Latest Event: {row.latest_event}")
    except Exception as e:
        print(f"  Could not verify data: {e}")

def main():
    """Main execution"""
    print("=" * 60)
    print("GA4 EVENT STREAMING SCRIPT")
    print("=" * 60)
    
    # Initialize client and create table
    client = create_streaming_table()
    
    # Stream events
    stream_events(
        client=client,
        num_events=20,  # Number of events to generate
        delay=1         # Seconds between events
    )
    
    # Verify data
    verify_data(client)
    
    print("\n Script complete!")
    print(" Check BigQuery console to see your streamed events")

if __name__ == "__main__":
    main()
