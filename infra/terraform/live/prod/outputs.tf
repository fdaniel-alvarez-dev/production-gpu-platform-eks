output "vpc_id" {
  value = module.foundation.vpc_id
}

output "private_subnet_ids" {
  value = module.foundation.private_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "ecr_repositories" {
  value = module.ecr.repository_urls
}

output "amp_workspace_id" {
  value = module.observability.amp_workspace_id
}

output "amg_workspace_id" {
  value = module.observability.amg_workspace_id
}
