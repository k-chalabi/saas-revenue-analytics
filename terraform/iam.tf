
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
  member  = google_service_account.ingestion.member
}

resource "google_project_iam_member" "dbt_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.dbt.member
}

resource "google_project_iam_member" "dbt_ci_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.dbt_ci.member
}

# ------------------------------------------------------------
# PROD - BigQuery Job Permissions
# ------------------------------------------------------------

resource "google_project_iam_member" "ingestion_prod_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.ingestion_prod.member
}

resource "google_project_iam_member" "dbt_prod_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.dbt_prod.member
}

# ------------------------------------------------------------
# PROD - Power BI Permissions
# ------------------------------------------------------------

resource "google_project_iam_member" "powerbi_job_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.powerbi.member
}

resource "google_project_iam_member" "powerbi_read_session_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.readSessionUser"
  member  = google_service_account.powerbi.member
}


# ------------------------------------------------------------
# GCS Bucket IAM - Data Ingestion
# ------------------------------------------------------------
# Manage existing permissions on the RAW storage bucket.

# ------------------------------------------------------------
# DEV / CI - GCS Object Access
# ------------------------------------------------------------

resource "google_storage_bucket_iam_member" "ingestion_raw_viewer" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.ingestion.member
}

# ------------------------------------------------------------
# PROD - GCS Object Access
# ------------------------------------------------------------

resource "google_storage_bucket_iam_member" "ingestion_prod_raw_viewer" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.ingestion_prod.member
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
# CI - GCS IAM Policy Read Access
# ------------------------------------------------------------
# Allow Terraform CI to read GCS bucket IAM policies during planning.

resource "google_project_iam_custom_role" "terraform_ci_bucket_iam_reader" {
  project     = "saas-revenue-analytics-507122"
  role_id     = "terraformCIBucketIAMReader"
  title       = "Terraform CI Bucket IAM Reader"
  description = "Read GCS bucket IAM policies during Terraform planning"

  permissions = [
    "storage.buckets.getIamPolicy"
  ]
}

resource "google_project_iam_member" "terraform_ci_bucket_iam_reader" {
  project = "saas-revenue-analytics-507122"
  role    = google_project_iam_custom_role.terraform_ci_bucket_iam_reader.id
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


# ------------------------------------------------------------
# Terraform CD IAM - Workload Identity Federation
# ------------------------------------------------------------
# Manage GitHub Actions access to the Terraform CD service account.

# ------------------------------------------------------------
# CD - GitHub Actions Authentication
# ------------------------------------------------------------
# Allow Terraform CD impersonation only from the approved
# deployment workflow on main using terraform-deploy.

resource "google_service_account_iam_member" "terraform_cd_wif" {
  service_account_id = google_service_account.terraform_cd.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.terraform_cd/authorized"
}

# ------------------------------------------------------------
# CD - Service Account Management
# ------------------------------------------------------------
# Allow Terraform CD to create and manage service accounts.

resource "google_project_iam_member" "terraform_cd_service_account_admin" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/iam.serviceAccountAdmin"
  member  = google_service_account.terraform_cd.member
}

# ------------------------------------------------------------
# CD - Cloud Storage Management
# ------------------------------------------------------------
# Allow Terraform CD to manage Cloud Storage buckets and objects.

resource "google_project_iam_member" "terraform_cd_storage_admin" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/storage.admin"
  member  = google_service_account.terraform_cd.member
}

# ------------------------------------------------------------
# CD - BigQuery Management
# ------------------------------------------------------------
# Allow Terraform CD to create and manage BigQuery datasets.

resource "google_project_iam_member" "terraform_cd_bigquery_user" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.user"
  member  = google_service_account.terraform_cd.member
}

resource "google_project_iam_member" "terraform_cd_bigquery_data_owner" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/bigquery.dataOwner"
  member  = google_service_account.terraform_cd.member
}

# ------------------------------------------------------------
# CD - Project IAM Management
# ------------------------------------------------------------
# Allow Terraform CD to manage project IAM permissions.

resource "google_project_iam_member" "terraform_cd_project_iam_admin" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = google_service_account.terraform_cd.member
}

# ------------------------------------------------------------
# CD - Workload Identity Federation Management
# ------------------------------------------------------------
# Allow Terraform CD to manage workload identity pools and providers.

resource "google_project_iam_member" "terraform_cd_workload_identity_pool_admin" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = google_service_account.terraform_cd.member
}

# ------------------------------------------------------------
# CD - Custom IAM Role Management
# ------------------------------------------------------------
# Allow Terraform CD to create and manage custom IAM roles.

resource "google_project_iam_member" "terraform_cd_role_admin" {
  project = "saas-revenue-analytics-507122"
  role    = "roles/iam.roleAdmin"
  member  = google_service_account.terraform_cd.member
}