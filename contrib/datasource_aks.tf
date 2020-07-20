# ################
# variables
# ################
variable "k8s_class_aks_name" {
  default = "k8s-class-aks"
}
variable "az_client_id" {}
variable "az_client_secret" {}

#################
# Resources
#################
resource "azurerm_resource_group" "k8s_class_aks" {
  name     = var.k8s_class_aks_name
  location = "West US"
}

resource "azurerm_kubernetes_cluster" "k8s_class_aks" {
  name                = var.k8s_class_aks_name
  location            = azurerm_resource_group.k8s_class_aks.location
  resource_group_name = azurerm_resource_group.k8s_class_aks.name
  dns_prefix          = "k8sClassAKS"

  default_node_pool {
    name       = "k8sclass"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  service_principal {
    client_id     = var.az_client_id
    client_secret = var.az_client_secret
  }

  tags = var.default_tags
}

provider "kubernetes" {
  alias = "aks"

  version          = "~> 1.11"
  load_config_file = false

  host                   = azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.host
  username               = azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.username
  password               = azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.cluster_ca_certificate)
}

resource "sdm_resource" "k8s_class_aks" {
  aks {
    name = var.k8s_class_aks_name

    hostname = azurerm_kubernetes_cluster.k8s_class_aks.fqdn
    port     = 443

    certificate_authority          = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.cluster_ca_certificate)
    certificate_authority_filename = "random_sting_ca"

    client_certificate          = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.client_certificate)
    client_certificate_filename = "random_sting_cc"

    client_key          = base64decode(azurerm_kubernetes_cluster.k8s_class_aks.kube_config.0.client_key)
    client_key_filename = "random_sting_ck"

    # healthcheck_namespace = "default"
  }
}
resource "sdm_role_grant" "k8s_class_aks" {
  role_id     = sdm_role.eks_clusters.id
  resource_id = sdm_resource.k8s_class_aks.id
}

module "aws_aks_sdm_gateway" {
  source = "github.com/peteroneilljr/terraform_aws_eks_strongdm_gateways"

  sdm_port         = 5000
  sdm_app_name     = var.k8s_class_aks_name
  sdm_gateway_name = "${var.k8s_class_aks_name}-gateway"
  gateway_count    = 1

  dev_mode = true

  providers = {
    kubernetes = kubernetes.aks
  }
}