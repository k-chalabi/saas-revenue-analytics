
# Use the official Airflow image, which already includes Python
# and the dependencies required to run Airflow.
FROM apache/airflow:3.1.8

# Switch to root to create a dedicated Python environment for dbt.
USER root

# Create a separate Python virtual environment for dbt.
# This isolates dbt dependencies from Airflow's Python environment
# and avoids potential dependency conflicts between both tools.
RUN python -m venv /opt/dbt-venv

# Install dbt Core and its BigQuery adapter inside this environment.
# Airflow will later use dbt to execute our data transformations.
RUN /opt/dbt-venv/bin/pip install --no-cache-dir \
    "dbt-core==1.12.4" \
    "dbt-bigquery==1.12.1"

# Return to the non-root Airflow user for security.
USER airflow

