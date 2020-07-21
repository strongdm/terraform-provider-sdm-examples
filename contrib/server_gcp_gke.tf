#################
# Variables
#################
variable "k8s_class_gke_location" {
  default = "us-west1"
}
variable "k8s_class_gke_name" {
  default = "k8s-class-gke"
}
variable "k8s_class_gke_node_count" {
  default = 1
}
variable "k8s_class_gke_username" {
  default = "k8sclassadministrator"
}
resource "random_password" "k8s_class_gke" {
  length           = 26
  special          = true
  override_special = "_%@"
}

# ################
# Create GKE cluster
# ################
resource "google_container_cluster" "k8s_class_gke" {
  name     = var.k8s_class_gke_name
  location = var.k8s_class_gke_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = var.k8s_class_gke_username
    password = random_password.k8s_class_gke.result

    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

resource "google_container_node_pool" "k8s_class_gke_preemptible_nodes" {
  name       = "${var.k8s_class_gke_name}-pool"
  location   = var.k8s_class_gke_location
  cluster    = google_container_cluster.k8s_class_gke.name
  node_count = var.k8s_class_gke_node_count

  node_config {
    preemptible  = true
    machine_type = "n2-standard-2"

    metadata = {
      disable-legacy-endpoints = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# # ################
# # Kubernetes provider 
# # ################

provider "kubernetes" {
  alias = "gke"

  version          = "~> 1.11"
  load_config_file = false

  host = "https://${google_container_cluster.k8s_class_gke.endpoint}"

  client_certificate     = base64decode(google_container_cluster.k8s_class_gke.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.k8s_class_gke.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.k8s_class_gke.master_auth.0.cluster_ca_certificate)

  username = google_container_cluster.k8s_class_gke.master_auth.0.username
  password = google_container_cluster.k8s_class_gke.master_auth.0.password
}

#################
# IAM access
#################
resource "google_project_iam_member" "k8s_class_gke" {
  project = google_service_account.k8s_class_gke.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.k8s_class_gke.email}"
}
resource "google_service_account" "k8s_class_gke" {
  account_id   = "sdm-gke-service-account"
  display_name = "sdm-gke-service-account"
  description  = "gke access"
}
resource "google_service_account_key" "k8s_class_gke" {
  service_account_id = google_service_account.k8s_class_gke.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
# #################
# # SDM control
# #################
resource "sdm_resource" "k8s_class_gke" {
  google_gke {
    name = var.k8s_class_gke_name

    endpoint = google_container_cluster.k8s_class_gke.endpoint

    certificate_authority          = base64decode(google_container_cluster.k8s_class_gke.master_auth.0.cluster_ca_certificate)
    certificate_authority_filename = "random_string_ca"

    service_account_key          = base64decode(google_service_account_key.k8s_class_gke.private_key)
    service_account_key_filename = "random_string_sak"

    # healthcheck_namespace = "default"
  }
}
resource "sdm_role_grant" "k8s_class_gke" {
  role_id     = sdm_role.eks_clusters.id
  resource_id = sdm_resource.k8s_class_gke.id
}

#################
# Create strongDM gateway in GKE cluster
#################
module "aws_gke_sdm_gateway" {
  source = "github.com/peteroneilljr/terraform_aws_eks_strongdm_gateways"

  sdm_port         = 5000
  sdm_app_name     = var.k8s_class_gke_name
  sdm_gateway_name = "${var.k8s_class_gke_name}-gateway"
  gateway_count    = 1

  dev_mode = true

  providers = {
    kubernetes = kubernetes.gke
  }
}