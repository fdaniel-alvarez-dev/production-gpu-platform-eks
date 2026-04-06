#!/usr/bin/env bash
set -euo pipefail

kubectl -n training-platform get jobs
kubectl -n training-platform describe resourcequota training-quota
