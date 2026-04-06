# ADR-001 — AWS-first implementation for a production GPU platform

## Status
Accepted

## Context

The target role expects strong hands-on AWS, Kubernetes, Terraform, CI/CD, and GPU workload awareness. The source material also describes a production-grade AWS/EKS operating model across foundation, GitOps, GPU enablement, observability, security, and cost control.

## Decision

Implement the reference platform on AWS first, using:

- Terraform for infrastructure
- EKS for Kubernetes
- Argo CD for GitOps
- Karpenter for compute elasticity
- NVIDIA GPU Operator for GPU lifecycle
- AMP / AMG for observability
- Kyverno and Pod Identity for security baseline

## Consequences

### Positive
- Strong alignment with the role requirements
- Clear production story
- Faster path to a functioning GPU platform
- Better demonstration of client-facing trade-off judgment

### Negative
- Some manifests and modules are AWS-specific
- The repo needs a render/bootstrap step for self-referential GitOps URLs
