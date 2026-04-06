#!/usr/bin/env bash
set -euo pipefail

kubectl -n inference-gateway get rollout inference-gateway
kubectl -n inference-gateway get svc inference-gateway-stable
