# #################
# # Register EKS with a user specified in configmap/aws-auth
# #################
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.14"
  subnets         = module.eks_vpc.public_subnets
  vpc_id          = module.eks_vpc.vpc_id

  map_users = [{
    userarn  = aws_iam_user.eks_user.arn
    username = split("/", aws_iam_user.eks_user.arn)[length(split("/", aws_iam_user.eks_user.arn)) - 1]
    groups   = ["system:masters"]
  }]
  worker_groups = [
    {
      instance_type    = "t3.small"
      desired_capacity = 2
    }
  ]
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
resource "aws_iam_user" "eks_user" {
  name = "eks_user"
  path = "/terraform/"
}
resource "aws_iam_access_key" "eks_user" {
  user = aws_iam_user.eks_user.name
}
resource "aws_iam_user_policy" "eks_user" {
  name = "eks_user"
  user = aws_iam_user.eks_user.name
}
resource "sdm_role_grant" "eks" {
  role_id     = sdm_role.eks_clusters.id
  resource_id = sdm_resource.eks.id
}
resource "sdm_resource" "eks" {
  amazon_eks {
    name         = "sdm-${data.aws_eks_cluster.cluster.name}"
    cluster_name = data.aws_eks_cluster.cluster.name

    endpoint = split("//", data.aws_eks_cluster.cluster.endpoint)[1]
    region   = split(".", data.aws_eks_cluster.cluster.endpoint)[2]

    certificate_authority          = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    certificate_authority_filename = "random_sting"

    access_key        = aws_iam_access_key.eks_user.id
    secret_access_key = aws_iam_access_key.eks_user.secret
  }
}