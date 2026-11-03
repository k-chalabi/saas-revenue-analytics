
# ------------------------------------------------------------
# Project IAM - BigQuery
# ------------------------------------------------------------
# Manage existing project-level IAM permissions.
# Use non-authoritative IAM member resources to preserve
# other permissions granted in the GCP project.

# ------------------------------------------------------------
# DEV / CI - BigQuery Job Permissions
# ------------------------------------------------------------

resource "google_project_iam_member" "ingestion_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:ingestion-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dbt_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:dbt-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dbt_ci_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:dbt-ci-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

# ------------------------------------------------------------
# PROD - BigQuery Job Permissions
# ------------------------------------------------------------

resource "google_project_iam_member" "ingestion_prod_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:ingestion-prod-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dbt_prod_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:dbt-prod-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

# ------------------------------------------------------------
# PROD - Power BI Permissions
# ------------------------------------------------------------

resource "google_project_iam_member" "powerbi_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:powerbi-reader@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "powerbi_read_session_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.readSessionUser"
  member  = "serviceAccount:powerbi-reader@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}


# ------------------------------------------------------------
# GCS Bucket IAM - Data Ingestion
# ------------------------------------------------------------
# Manage existing permissions on the RAW storage bucket.

# ------------------------------------------------------------
# DEV / CI - GCS Object Access
# ------------------------------------------------------------

resource "google_storage_bucket_iam_member" "ingestion_raw_viewer" {
  bucket = "saas-revenue-analytics-raw"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:ingestion-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}

# ------------------------------------------------------------
# PROD - GCS Object Access
# ------------------------------------------------------------

resource "google_storage_bucket_iam_member" "ingestion_prod_raw_viewer" {
  bucket = "saas-revenue-analytics-raw"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:ingestion-prod-service-account@saas-revenue-analytics-507122.iam.gserviceaccount.com"
}
