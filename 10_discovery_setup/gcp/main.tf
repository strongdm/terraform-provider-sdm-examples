terraform {
  required_version = ">= 1.5.0"

  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = "~> 16"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0"
    }
  }
}

# The Google providers use the project from GOOGLE_PROJECT env var or gcloud config
# The Workload Identity Pool is created in this project
provider "google" {
}

provider "google-beta" {
}

# Get the current project info (where Workload Identity Pool will be created)
data "google_project" "identity" {}

provider "sdm" {
  # Authentication is typically handled via:
  # SDM_API_ACCESS_KEY and SDM_API_SECRET_KEY environment variables
  # or through setting api_access_key and api_secret_key here
}

data "sdm_org_url_info" "org" {
}

# Create the StrongDM discovery connector for GCP
resource "sdm_connector" "gcp_discovery" {
  gcp {
    name                    = var.connector_name
    description             = "Discovers resources across GCP projects: ${join(", ", var.project_ids)}"
    scan_period             = var.scan_period
    project_ids             = var.project_ids
    services                = var.services
    workload_project_number = data.google_project.identity.number
    workload_project_id     = data.google_project.identity.project_id
    workload_provider_id    = var.provider_id
    workload_pool_id        = var.pool_id
  }
}

locals {
  subject = "sdm:${var.sdm_website_subdomain}:${sdm_connector.gcp_discovery.id}"
}

# Create Workload Identity Pool for StrongDM federation
resource "google_iam_workload_identity_pool" "sdm" {
  provider                  = google-beta
  project                   = data.google_project.identity.project_id
  workload_identity_pool_id = var.pool_id

  display_name = "StrongDM Discovery Pool"
  description  = "Workload Identity Pool for StrongDM discovery federation"
}

# Create OIDC Provider for StrongDM
resource "google_iam_workload_identity_pool_provider" "sdm_oidc" {
  provider                           = google-beta
  project                            = data.google_project.identity.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.sdm.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id

  display_name = "StrongDM Discovery OIDC Provider"
  description  = "OIDC provider for StrongDM discovery federation"

  attribute_mapping = {
    "google.subject"            = "assertion.sub"
    "attribute.aud"             = "assertion.aud"
    "attribute.strongdm_issuer" = "assertion.iss"
  }

  oidc {
    issuer_uri        = data.sdm_org_url_info.org.oidc_issuer_url
    allowed_audiences = ["sdm:${var.sdm_website_subdomain}"]
  }
}

locals {
  pool_resource_name = "projects/${data.google_project.identity.number}/locations/global/workloadIdentityPools/${var.pool_id}"
  principal_subject  = "principal://iam.googleapis.com/${local.pool_resource_name}/subject/${local.subject}"
}

# Grant Viewer role across all target projects
resource "google_project_iam_member" "viewer_in_targets" {
  for_each = toset(var.project_ids)

  project = each.value
  role    = "roles/viewer"
  member  = local.principal_subject
}
