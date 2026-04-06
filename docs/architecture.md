# Architecture

This platform is intentionally split into layers so each failure domain stays understandable.

## Layer 1 — Foundation AWS

- Dedicated VPC
- Three Availability Zones
- Public subnets only for edge components
- Private subnets for workers and workloads
- NAT per AZ
- VPC endpoints for S3, ECR, STS, CloudWatch, Secrets Manager
- S3 for models, checkpoints, and artifacts
- EFS for shared filesystem patterns
- KMS-backed encryption and mandatory tagging

This follows the foundation principles in the source design: private-first networking, minimal exposure, and strong tagging from day one.

## Layer 2 — Cluster management

Argo CD is the management plane.

- App of Apps for bootstrap
- ApplicationSets for domain-based rollout
- Sync waves to make CRDs and operators land before custom resources
- Separate AppProjects for platform-core, gpu-platform, inference, training, security, and observability

That ordering is what keeps GPU Operator, Karpenter, Rollouts, monitoring, and policy controllers from fighting each other during bootstrap.

## Layer 3 — Compute pools

- General pool: non-GPU platform workloads only
- Inference pool: low-latency GPU serving
- Training pool: throughput-heavy, checkpoint-aware workloads

The split is deliberate. Inference and training have different latency, interruption, and storage profiles.

## Layer 4 — GPU enablement

The repo uses NVIDIA GPU Operator as the production default.

Why:
- lifecycle management
- less driver drift
- DCGM metrics available by design
- future-ready for DRA

Manual driver + toolkit installation is acceptable for narrow debugging or tiny clusters, but not as the production default.

## Layer 5 — Progressive delivery

Inference services use Argo Rollouts with canary or blue-green patterns, stable/canary services, and metric-based gates.

That matters because a GPU serving failure is rarely just an HTTP problem. It can be warm-up latency, memory pressure, CUDA instability, or model-level regression.

## Layer 6 — Observability

The default production stance is managed observability:

- AMP for metrics storage
- AMG for dashboards and alerts
- DCGM Exporter for GPU metrics
- recording and alert rules in Git

That avoids competing with workloads for local cluster resources.

## Layer 7 — Security

The repo stages security in this order:

- Pod Identity / IRSA fallback
- External Secrets
- Kyverno policies from audit to enforce
- namespace-level network policies
- image verification
- restrictive pod security for application workloads, with explicit exceptions for privileged operator namespaces

That sequence avoids the common mistake of turning on full policy enforcement before the platform is actually compatible with it.

## Layer 8 — FinOps and tenancy

- Kubecost for showback and chargeback
- tags and labels as mandatory cost dimensions
- schedules for non-production savings
- training on Spot with checkpointing
- inference on stable baseline capacity first
- namespaces, RBAC, quotas, and auditability for multi-team usage

This is not “cost optimization at the end.” It is part of the platform contract.
