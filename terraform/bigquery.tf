
# ------------------------------------------------------------
# BigQuery Datasets
# ------------------------------------------------------------
# Manage existing BigQuery datasets across DEV, CI, and PROD.
# All datasets are located in the US multi-region.


# ------------------------------------------------------------
# DEV & CI - RAW
# ------------------------------------------------------------

resource "google_bigquery_dataset" "raw_dev" {
  dataset_id = "raw_dev"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Dataset administration
  access {
    role          = "OWNER"
    user_by_email = "karim.chalabiii@gmail.com"
  }

  # DEV ingestion
  access {
    role          = "WRITER"
    user_by_email = google_service_account.ingestion.email
  }

  # DEV dbt transformations
  access {
    role          = "READER"
    user_by_email = google_service_account.dbt.email
  }

  # CI dbt transformations
  access {
    role          = "READER"
    user_by_email = google_service_account.dbt_ci.email
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# DEV - dbt Models
# ------------------------------------------------------------

resource "google_bigquery_dataset" "dbt_karim" {
  dataset_id = "dbt_karim"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # DEV dbt transformations
  access {
    role          = "WRITER"
    user_by_email = google_service_account.dbt.email
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# CI - dbt Models
# ------------------------------------------------------------

resource "google_bigquery_dataset" "dbt_ci" {
  dataset_id = "dbt_ci"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Dataset administration
  access {
    role          = "OWNER"
    user_by_email = "karim.chalabiii@gmail.com"
  }

  # CI dbt transformations
  access {
    role          = "WRITER"
    user_by_email = google_service_account.dbt_ci.email
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# PROD - RAW
# ------------------------------------------------------------

resource "google_bigquery_dataset" "raw" {
  dataset_id = "raw"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Dataset administration
  access {
    role          = "OWNER"
    user_by_email = "karim.chalabiii@gmail.com"
  }

  # PROD ingestion
  access {
    role          = "WRITER"
    user_by_email = google_service_account.ingestion_prod.email
  }

  # PROD dbt transformations
  access {
    role          = "READER"
    user_by_email = google_service_account.dbt_prod.email
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# PROD - dbt Technical Models (Staging & Intermediate)
# ------------------------------------------------------------

resource "google_bigquery_dataset" "dbt_prod_technical" {
  dataset_id = "dbt_prod_technical"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Dataset administration
  access {
    role          = "OWNER"
    user_by_email = "karim.chalabiii@gmail.com"
  }

  # PROD dbt transformations
  access {
    role          = "WRITER"
    user_by_email = google_service_account.dbt_prod.email
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# PROD - Analytics Marts (Power BI)
# ------------------------------------------------------------

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "analytics"
  project    = "saas-revenue-analytics-507122"
  location   = "US"

  max_time_travel_hours = 168

  # Project-level default access
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  # Dataset administration
  access {
    role          = "OWNER"
    user_by_email = "karim.chalabiii@gmail.com"
  }

  # PROD dbt transformations
  access {
    role          = "WRITER"
    user_by_email = google_service_account.dbt_prod.email
  }

  # Power BI reporting
  access {
    role          = "READER"
    user_by_email = google_service_account.powerbi.email
  }

  lifecycle {
    prevent_destroy = true
  }
}

