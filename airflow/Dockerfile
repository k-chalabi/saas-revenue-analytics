FROM apache/airflow:3.1.8

USER root

RUN python -m venv /opt/dbt-venv

RUN /opt/dbt-venv/bin/pip install --no-cache-dir \
    "dbt-core==1.12.4" \
    "dbt-bigquery==1.12.1"

USER airflow