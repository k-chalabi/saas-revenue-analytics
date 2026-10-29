
from datetime import datetime

from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.trigger_dagrun import TriggerDagRunOperator


# This DAG runs the complete PROD pipeline:
# 1. Load source files from GCS into BigQuery PROD RAW.
# 2. Run dbt transformations in the PROD environment.
with DAG(
    dag_id="saas_revenue_pipeline_prod",
    description="Orchestrate RAW ingestion and dbt PROD transformations",
    start_date=datetime(2026, 10, 1),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["saas-revenue", "prod", "orchestration"],
) as dag:

    # Trigger the ingestion DAG and wait until it finishes.
    # If ingestion fails, the dbt task will not start.
    ingest_raw = TriggerDagRunOperator(
        task_id="ingest_raw",
        trigger_dag_id="gcs_to_bigquery_raw",
        wait_for_completion=True,
        poke_interval=10,
        allowed_states=["success"],
        failed_states=["failed"],
    )

    # Run all dbt models and tests in the PROD environment.
    # dbt uses the PROD service account configured in Docker.
    run_dbt = BashOperator(
        task_id="run_dbt",
        bash_command=(
            "cd /opt/airflow/dbt && "
            "/opt/dbt-venv/bin/dbt build --target prod"
        ),
    )

    # Run dbt only after RAW ingestion succeeds.
    ingest_raw >> run_dbt