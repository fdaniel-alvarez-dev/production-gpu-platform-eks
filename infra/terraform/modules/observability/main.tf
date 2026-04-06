resource "aws_prometheus_workspace" "this" {
  alias = "${var.platform_name}-${var.environment}"
  tags  = var.tags
}

resource "aws_grafana_workspace" "this" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  name                     = "${var.platform_name}-${var.environment}"
  data_sources             = ["PROMETHEUS", "CLOUDWATCH"]
  tags                     = var.tags
}

output "amp_workspace_id" { value = aws_prometheus_workspace.this.id }
output "amg_workspace_id" { value = aws_grafana_workspace.this.id }
