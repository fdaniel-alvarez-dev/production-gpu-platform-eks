#!/usr/bin/env bash
set -euo pipefail

: "${REPO_URL:=https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git}"
REPO_URL="${REPO_URL}" bash ./scripts/render_bootstrap.sh >/dev/null

python3 scripts/yaml_sanity_check.py platform-gitops platform-apps rendered

kustomize build rendered/platform-gitops/projects >/dev/null
kustomize build rendered/platform-gitops/applicationsets >/dev/null
kustomize build platform-gitops/clusters/prod-us-east-1 >/dev/null
kustomize build platform-gitops/tenancy >/dev/null

for app in platform-apps/environments/prod/*; do
  if [[ -f "${app}/kustomization.yaml" ]]; then
    kustomize build "${app}" >/dev/null
  fi
done
