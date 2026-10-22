# Use the official Apache Airflow image as the base.
FROM apache/airflow:3.1.8

# Switch to root to create the dbt virtual environment.
USER root

# Keep dbt dependencies separate from Airflow to avoid version conflicts.
RUN python -m venv /opt/dbt-venv

# Install the dbt packages required to run transformations in BigQuery.
RUN /opt/dbt-venv/bin/pip install --no-cache-dir \
    "dbt-core==1.12.4" \
    "dbt-bigquery==1.12.1"

# Run Airflow with its default non-root user.
USER airflow
