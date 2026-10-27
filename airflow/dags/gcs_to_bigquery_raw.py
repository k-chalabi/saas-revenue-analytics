import os
from datetime import datetime

from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import (
    GCSToBigQueryOperator,
)


# Google Cloud resources used for RAW data ingestion.
# The Airflow connection uses a dedicated ingestion service account.
PROJECT_ID = "saas-revenue-analytics-507122"
GCS_BUCKET = "saas-revenue-analytics-raw"
BQ_DATASET = os.environ["BQ_RAW_DATASET"]
GCP_CONN_ID = "google_cloud_ingestion"


# Load source CSV files from GCS into the BigQuery RAW dataset.
# This DAG can also be triggered by the DEV or PROD pipeline.
with DAG(
    dag_id="gcs_to_bigquery_raw",
    description="Ingest raw SaaS source files from GCS into BigQuery",
    start_date=datetime(2026, 10, 1),
    schedule=None,
    catchup=False,
    tags=["GCS", "BigQuery", "RAW"],
) as dag:

    # List of source tables to ingest.
    # Each table has a matching CSV file in the GCS bucket.
    source_tables = [
        "hubspot_companies",
        "subskribe_accounts",
        "subskribe_invoices",
        "subskribe_subscriptions",
    ]

    # Create one independent ingestion task per source table.
    # Airflow can execute these tasks in parallel.
    for table in source_tables:
        GCSToBigQueryOperator(
            task_id=f"ingest_{table}",
            bucket=GCS_BUCKET,
            source_objects=[f"raw/{table}.csv"],
            destination_project_dataset_table=(
                f"{PROJECT_ID}.{BQ_DATASET}.{table}"
            ),

            # Read CSV files, skip the header and detect column types.
            source_format="CSV",
            skip_leading_rows=1,
            autodetect=True,

            # Replace existing data on each run, or create missing tables.
            write_disposition="WRITE_TRUNCATE",
            create_disposition="CREATE_IF_NEEDED",

            # Use the BigQuery US location and ingestion credentials.
            location="US",
            gcp_conn_id=GCP_CONN_ID,
        )
