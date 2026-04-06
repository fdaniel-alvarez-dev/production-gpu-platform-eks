locals {
  repositories = toset([
    "inference-gateway",
    "training-runner",
    "platform-tools"
  ])
}

resource "aws_ecr_repository" "this" {
  for_each             = local.repositories
  name                 = "${var.platform_name}/${var.environment}/${each.value}"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-${each.value}"
  })
}

output "repository_urls" {
  value = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}
