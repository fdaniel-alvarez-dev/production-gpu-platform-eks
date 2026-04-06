locals {
  common_tags = merge({
    environment = var.environment
    platform    = var.platform_name
    managed-by  = "terraform"
    repository  = "production-gpu-platform-eks"
  }, var.tags)
}
