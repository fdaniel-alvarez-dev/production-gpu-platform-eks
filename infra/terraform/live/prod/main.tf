module "foundation" {
  source               = "../../modules/foundation"
  platform_name        = var.platform_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "ecr" {
  source        = "../../modules/ecr"
  platform_name = var.platform_name
  environment   = var.environment
  tags          = local.common_tags
}

module "eks" {
  source                 = "../../modules/eks"
  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = module.foundation.vpc_id
  private_subnet_ids     = module.foundation.private_subnet_ids
  general_instance_types = var.general_instance_types
  general_desired_size   = var.general_desired_size
  general_min_size       = var.general_min_size
  general_max_size       = var.general_max_size
  tags                   = local.common_tags
}

module "observability" {
  source        = "../../modules/observability"
  platform_name = var.platform_name
  environment   = var.environment
  tags          = local.common_tags
}
