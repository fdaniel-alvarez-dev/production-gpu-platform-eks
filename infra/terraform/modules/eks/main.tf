module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    general = {
      instance_types = var.general_instance_types
      desired_size   = var.general_desired_size
      min_size       = var.general_min_size
      max_size       = var.general_max_size
      ami_type       = "AL2023_x86_64_STANDARD"
      labels = {
        workload-type = "general"
      }
      taints = []
    }
  }

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {}
  }

  tags = var.tags
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
output "cluster_security_group_id" { value = module.eks.cluster_security_group_id }
