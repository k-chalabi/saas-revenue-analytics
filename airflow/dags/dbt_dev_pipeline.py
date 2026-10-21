from datetime import datetime

from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator


with DAG(
    dag_id="dbt_dev_pipeline",
    start_date=datetime(2026, 10, 1),
    schedule=None,
    catchup=False,
    tags=["dbt", "dev"],
) as dag:

    run_dbt = BashOperator(
        task_id="run_dbt",
        bash_command=(
            "cd /opt/airflow/dbt && "
            "/opt/dbt-venv/bin/dbt build --target dev"
        ),
    )