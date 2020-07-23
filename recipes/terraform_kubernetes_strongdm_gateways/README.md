# strongDM Gateways Deployed with Kubernetes 

Example Usage
~~~
data "aws_eks_cluster" "k8s_class" {
  name = "k8s-class"
}

data "aws_eks_cluster_auth" "k8s_class" {
  name = data.aws_eks_cluster.k8s_class.id
}

provider "kubernetes" {
  alias = "eks"

  host                   = data.aws_eks_cluster.k8s_class.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8s_class.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.k8s_class.token
  load_config_file       = false
}

module "aws_eks_sdm_gateway" {
  source = "github.com/peteroneilljr/terraform_aws_eks_strongdm_gateways"
  
  sdm_port = 5000
  sdm_app_name = "sdm-gateway"
  sdm_gateway_name = "aws-eks-gateway"
  gateway_count = 1
  namespace = "sdm-gateway"

  dev_mode = false

  providers = {
    kubernetes = "kubernetes.eks"
  }
} 
~~~
