#!/usr/bin/env bash
set -euo pipefail

terraform fmt -check -recursive infra/terraform
terraform -chdir=infra/terraform/live/prod init -backend=false >/dev/null
terraform -chdir=infra/terraform/live/prod validate
