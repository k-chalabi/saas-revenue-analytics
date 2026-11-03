
# ------------------------------------------------------------
# Workload Identity Federation - GitHub Actions
# ------------------------------------------------------------
# Allow GitHub Actions to authenticate to GCP
# without storing service account keys.

# ------------------------------------------------------------
# GitHub Workload Identity Pool
# ------------------------------------------------------------

resource "google_iam_workload_identity_pool" "github" {
  project                   = "saas-revenue-analytics-507122"
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "Workload identity pool for GitHub Actions"
  disabled                  = false

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------
# GitHub OIDC Provider
# ------------------------------------------------------------
# Verify GitHub Actions identity tokens and restrict access
# to the SaaS Revenue Analytics repository.

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = "saas-revenue-analytics-507122"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"

  display_name = "GitHub OIDC"
  description  = "OIDC provider for GitHub Actions"

  # Get the repository, owner and branch information from the GitHub token.
  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.repository"          = "assertion.repository"
    "attribute.repository_id"       = "assertion.repository_id"
    "attribute.repository_owner_id" = "assertion.repository_owner_id"
    "attribute.ref"                 = "assertion.ref"
  }

  # Accept tokens only from our GitHub repository and its owner.
  attribute_condition = "assertion.repository_id == '1372472439' && assertion.repository_owner_id == '226288651'"

  # Trust identity tokens issued by GitHub Actions.
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}



