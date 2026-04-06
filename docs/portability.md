# Portability Notes

This repository is AWS-first because that is the clearest implementation path for the current role focus:

- EKS
- Terraform
- Kubernetes compute environments
- CI/CD
- GPU workloads
- cost-aware architecture

The operating model is still portable.

## What is AWS-specific here

- VPC endpoints
- EKS
- Pod Identity / IRSA fallback
- ECR
- AMP / AMG
- AWS Load Balancer Controller assumptions

## What is portable by design

- GitOps structure
- AppProjects and domain boundaries
- GPU pool separation
- progressive delivery logic
- staged security policy model
- runbook structure
- cost and tagging discipline

If you later port the design to GKE, AKS, or OCI OKE, the highest-value parts to preserve are the operating boundaries, not the cloud-specific primitives.
