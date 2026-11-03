
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


# ------------------------------------------------------------
# Terraform CI IAM - Workload Identity Federation
# ------------------------------------------------------------
# Manage GitHub Actions access to the Terraform CI service account.

# ------------------------------------------------------------
# CI - GitHub Actions Authentication
# ------------------------------------------------------------

resource "google_service_account_iam_member" "terraform_ci_wif" {
  service_account_id = google_service_account.terraform_ci.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_id/1372472439"
}

# ------------------------------------------------------------
# CI - GCP Resource Access
# ------------------------------------------------------------

resource "google_project_iam_member" "terraform_ci_viewer" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/viewer"
  member  = google_service_account.terraform_ci.member
}

# ------------------------------------------------------------
# CI - Terraform State Access
# ------------------------------------------------------------

resource "google_storage_bucket_iam_member" "terraform_ci_state_viewer" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.terraform_ci.member
}

# ------------------------------------------------------------
# CI - Terraform State Lock Management
# ------------------------------------------------------------
# Define a custom IAM role for creating and deleting state locks.

resource "google_project_iam_custom_role" "terraform_ci_lock" {
  project     = "saas-revenue-analytics-507122"
  role_id     = "terraformCILock"
  title       = "Terraform CI State Lock"
  description = "Permissions required to create and delete Terraform state locks"

  permissions = [
    "storage.objects.create",
    "storage.objects.delete"
  ]
}

# ------------------------------------------------------------
# CI - Terraform State Lock Access
# ------------------------------------------------------------
# Restrict lock management permissions to the Terraform lock file.

resource "google_storage_bucket_iam_member" "terraform_ci_lock" {
  bucket = google_storage_bucket.tfstate.name
  role   = google_project_iam_custom_role.terraform_ci_lock.id
  member = google_service_account.terraform_ci.member

  condition {
    title       = "TerraformCILockOnly"
    description = "Allow lock management only for the Terraform state lock file"

    expression = "resource.type == 'storage.googleapis.com/Object' && resource.name == 'projects/_/buckets/saas-revenue-analytics-tfstate/objects/terraform/state/default.tflock'"
  }
}