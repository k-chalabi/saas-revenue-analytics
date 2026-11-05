
# ------------------------------------------------------------
# Terraform & Provider Versions
# ------------------------------------------------------------
# Define the required Terraform version and Google Cloud
# provider to ensure consistent infrastructure deployments.

terraform {
  # Terraform CLI version compatibility
  required_version = ">= 1.16.0, < 2.0.0"

  # Providers required to manage our cloud infrastructure
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0.0, < 8.0.0"
    }
  }
}

