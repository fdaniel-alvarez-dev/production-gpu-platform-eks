#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f platform-gitops/bootstrap/namespace-argocd.yaml
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1
helm upgrade --install argocd argo/argo-cd   --namespace argocd   --create-namespace   -f platform-gitops/bootstrap/argocd-values-prod.yaml
kubectl apply -f platform-gitops/bootstrap/argocd-cm-patch.yaml
kubectl apply -f platform-gitops/bootstrap/argocd-rbac-cm.yaml
kubectl apply -f rendered/platform-gitops/bootstrap/root-app.yaml
