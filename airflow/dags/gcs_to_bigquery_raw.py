from datetime import datetime

from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import (
    GCSToBigQueryOperator,
)


PROJECT_ID = "saas-revenue-analytics-507122"
GCS_BUCKET = "saas-revenue-analytics-raw"
BQ_DATASET = "raw"
GCP_CONN_ID = "google_cloud_ingestion"


with DAG(
    dag_id="gcs_to_bigquery_raw",
    description="Ingest raw SaaS source files from GCS into BigQuery",
    start_date=datetime(2026, 10, 1),
    schedule=None,
    catchup=False,
    tags=["GCS", "BigQuery", "RAW"],
) as dag:

    source_tables = [
        "hubspot_companies",
        "subskribe_accounts",
        "subskribe_invoices",
        "subskribe_subscriptions",
    ]

    for table in source_tables:
        GCSToBigQueryOperator(
            task_id=f"ingest_{table}",
            bucket=GCS_BUCKET,
            source_objects=[f"raw/{table}.csv"],
            destination_project_dataset_table=(
                f"{PROJECT_ID}.{BQ_DATASET}.{table}"
            ),
            source_format="CSV",
            skip_leading_rows=1,
            autodetect=True,
            write_disposition="WRITE_TRUNCATE",
            create_disposition="CREATE_IF_NEEDED",
            location="US",
            gcp_conn_id=GCP_CONN_ID,
        )