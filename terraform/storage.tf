
# ------------------------------------------------------------
# Google Cloud Storage Buckets
# ------------------------------------------------------------
# Manage existing GCS buckets used by the
# SaaS Revenue Analytics infrastructure.

# ------------------------------------------------------------
# RAW - Source Data Storage
# ------------------------------------------------------------

resource "google_storage_bucket" "raw" {
  name     = "saas-revenue-analytics-raw"
  project  = "saas-revenue-analytics-507122"
  location = "US"

  storage_class = "STANDARD"

  # Prevent public access to the bucket
  public_access_prevention = "enforced"

  # Use IAM exclusively for bucket-level permissions
  uniform_bucket_level_access = true

  # Preserve existing soft delete configuration
  soft_delete_policy {
    retention_duration_seconds = 0
  }

  # Preserve existing encryption restrictions
  encryption {
    customer_managed_encryption_enforcement_config {
      restriction_mode = "NotRestricted"
    }

    customer_supplied_encryption_enforcement_config {
      restriction_mode = "FullyRestricted"
    }

    google_managed_encryption_enforcement_config {
      restriction_mode = "NotRestricted"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}


# ------------------------------------------------------------
# Terraform State - Remote Backend Storage
# ------------------------------------------------------------

resource "google_storage_bucket" "tfstate" {
  name     = "saas-revenue-analytics-tfstate"
  project  = "saas-revenue-analytics-507122"
  location = "US"

  storage_class = "STANDARD"

  # Prevent public access to the bucket
  public_access_prevention = "enforced"

  # Use IAM exclusively for bucket-level permissions
  uniform_bucket_level_access = true

  # Preserve previous versions of Terraform state files
  versioning {
    enabled = true
  }

  # Retain deleted objects for 7 days
  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  # Protect the bucket containing Terraform's remote state
  lifecycle {
    prevent_destroy = true
  }
}

