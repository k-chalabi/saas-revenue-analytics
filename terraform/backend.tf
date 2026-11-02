
# ------------------------------------------------------------
# Terraform Remote State Backend
# ------------------------------------------------------------
# Store the Terraform state in a dedicated Google Cloud
# Storage bucket to enable centralized state management.
# Object versioning and soft delete protect previous states.

terraform {
  backend "gcs" {
    bucket = "saas-revenue-analytics-tfstate"
    prefix = "terraform/state"
  }
}
