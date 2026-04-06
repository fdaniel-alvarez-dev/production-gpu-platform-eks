#!/usr/bin/env bash
set -euo pipefail

: "${REPO_URL:?REPO_URL must be set}"

mkdir -p rendered/platform-gitops/bootstrap rendered/platform-gitops/applicationsets rendered/platform-gitops/projects

envsubst < platform-gitops/bootstrap/root-app.yaml.tmpl > rendered/platform-gitops/bootstrap/root-app.yaml
envsubst < platform-gitops/applicationsets/applicationset-platform.yaml.tmpl > rendered/platform-gitops/applicationsets/applicationset-platform.yaml
cp platform-gitops/applicationsets/kustomization.yaml rendered/platform-gitops/applicationsets/kustomization.yaml

envsubst < platform-gitops/projects/project-platform-core.yaml.tmpl > rendered/platform-gitops/projects/project-platform-core.yaml
envsubst < platform-gitops/projects/project-gpu-platform.yaml.tmpl > rendered/platform-gitops/projects/project-gpu-platform.yaml
envsubst < platform-gitops/projects/project-inference.yaml.tmpl > rendered/platform-gitops/projects/project-inference.yaml
envsubst < platform-gitops/projects/project-training.yaml.tmpl > rendered/platform-gitops/projects/project-training.yaml
envsubst < platform-gitops/projects/project-security.yaml.tmpl > rendered/platform-gitops/projects/project-security.yaml
envsubst < platform-gitops/projects/project-observability.yaml.tmpl > rendered/platform-gitops/projects/project-observability.yaml
envsubst < platform-gitops/projects/project-tenancy.yaml.tmpl > rendered/platform-gitops/projects/project-tenancy.yaml
cp platform-gitops/projects/kustomization.yaml rendered/platform-gitops/projects/kustomization.yaml

echo "Rendered bootstrap files under rendered/."
