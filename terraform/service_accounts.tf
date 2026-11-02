
# ------------------------------------------------------------
# IAM Service Accounts
# ------------------------------------------------------------
# Manage existing service accounts used by the
# SaaS Revenue Analytics infrastructure.

# ------------------------------------------------------------
# DEV / CI - Data Ingestion
# ------------------------------------------------------------

resource "google_service_account" "ingestion" {
  account_id   = "ingestion-service-account"
  display_name = "ingestion-service-account"
  description  = "Service account for GCS to BigQuery RAW ingestion via Airflow"
  disabled     = false
}

# ------------------------------------------------------------
# PROD - Data Ingestion
# ------------------------------------------------------------

resource "google_service_account" "ingestion_prod" {
  account_id   = "ingestion-prod-service-account"
  display_name = "ingestion-prod-service-account"
  description  = "Service account for GCS to BigQuery RAW production ingestion via Airflow"
  disabled     = false
}

# ------------------------------------------------------------
# DEV - dbt Transformations
# ------------------------------------------------------------

resource "google_service_account" "dbt" {
  account_id   = "dbt-service-account"
  display_name = "dbt-service-account"
  description  = "Service account used by dbt for development transformations"
  disabled     = false
}

# ------------------------------------------------------------
# CI - dbt Transformations
# ------------------------------------------------------------

resource "google_service_account" "dbt_ci" {
  account_id   = "dbt-ci-service-account"
  display_name = "dbt-ci-service-account"
  description  = "Service account for dbt CI workflows"
  disabled     = false
}

# ------------------------------------------------------------
# PROD - dbt Transformations
# ------------------------------------------------------------

resource "google_service_account" "dbt_prod" {
  account_id   = "dbt-prod-service-account"
  display_name = "dbt-prod-service-account"
  description  = "Service account used by dbt for production deployments"
  disabled     = false
}

# ------------------------------------------------------------
# PROD - Power BI
# ------------------------------------------------------------

resource "google_service_account" "powerbi" {
  account_id   = "powerbi-reader"
  display_name = "powerbi-reader"
  description  = "Service account used by Power BI to read production analytics marts"
  disabled     = false
}
