# Production GPU Platform on EKS

This repository provisions and bootstraps a production-grade GPU platform on AWS EKS with a strong emphasis on security, progressive delivery, observability, and cost control.

The design is AWS-first because that is the fastest path to a reliable GPU platform with EKS, Karpenter, NVIDIA GPU Operator, and managed observability. The structure also keeps the boundaries clean enough to extend the same operating model to GCP, Azure, or OCI later.

## What this repo covers

- Foundation AWS layer: VPC, private subnets, NAT, VPC endpoints, S3, EFS, KMS, baseline IAM
- EKS control plane and baseline general node group
- GitOps management plane with Argo CD, AppProjects, ApplicationSets, and sync waves
- Dedicated GPU compute patterns for inference and training
- NVIDIA GPU Operator, DCGM Exporter, GPU Feature Discovery, optional MIG hooks
- Progressive delivery for inference with Argo Rollouts
- Managed observability integration points for Amazon Managed Prometheus and Amazon Managed Grafana
- Security baseline with Pod Identity / IRSA fallback, Kyverno, network policies, signed image enforcement, and External Secrets hooks
- FinOps controls with Karpenter, Spot, Kubecost, schedules, and tagging
- Team guardrails with namespaces, RBAC, quotas, and auditability
- Example workload images for inference and training to prove the platform wiring end to end

## Why this repo looks opinionated

This repository intentionally chooses production-safe defaults:

- private-first networking
- one general node group plus dedicated GPU pools
- GitOps before workload sprawl
- GPU Operator instead of manual driver drift
- canary and auto-rollback for online inference
- cost visibility before scale
- security guardrails staged from audit to enforce

Those choices map directly to the role expectations: Kubernetes depth, Terraform fluency, CI/CD ownership, GPU workload awareness, client-facing trade-off thinking, and resilient cloud operations.

## High-level architecture

```text
GitHub -> CI validation -> Terraform apply -> EKS foundation
                           |
                           +-> Argo CD bootstrap -> ApplicationSets -> platform add-ons
                                                           |
                                                           +-> GPU Operator / Karpenter / Rollouts / Monitoring / Security
                                                           |
                                                           +-> Inference workloads / Training jobs
```

## Repository layout

```text
production-gpu-platform-eks/
├── docs/
│   ├── architecture.md
│   ├── deployment-order.md
│   ├── portability.md
│   ├── runbooks/
│   └── adr/
├── infra/
│   └── terraform/
│       ├── live/prod/
│       └── modules/
├── platform-gitops/
│   ├── bootstrap/
│   ├── clusters/prod-us-east-1/
│   ├── projects/
│   ├── applicationsets/
│   ├── monitoring/
│   ├── security/
│   ├── cost/
│   └── tenancy/
├── platform-apps/
│   └── environments/prod/
│       ├── gpu-operator/
│       ├── karpenter/
│       ├── storage-primitives/
│       ├── argo-rollouts/
│       ├── monitoring/
│       ├── security/
│       ├── cost/
│       ├── training-platform/
│       └── inference-gateway/
├── apps/
│   ├── inference-gateway/
│   └── training-jobs/
├── scripts/
└── .github/workflows/
```

## Deployment order

1. `infra/terraform/live/prod` – foundation, EKS, IAM, ECR, observability workspaces
2. `platform-gitops/bootstrap` – Argo CD namespace, Helm values, RBAC, ConfigMaps
3. `platform-gitops/clusters/prod-us-east-1` – root app
4. `platform-apps/environments/prod/gpu-operator`
5. `platform-apps/environments/prod/karpenter`
6. `platform-apps/environments/prod/storage-primitives`
7. `platform-apps/environments/prod/argo-rollouts`
8. `platform-apps/environments/prod/monitoring`
9. `platform-apps/environments/prod/security`
10. `platform-apps/environments/prod/training-platform`
11. `platform-apps/environments/prod/inference-gateway`
12. `platform-apps/environments/prod/cost`
13. `platform-gitops/tenancy`

The order above follows the same dependency logic from the source material: CRDs and operators first, workload-specific resources later.

## Production decisions (operators, metrics, and access)

This repo is intentionally opinionated about *how* platform controllers are installed and validated:

- Operators/controllers are installed via **Helm charts pinned to exact versions** (no floating tags, no implicit upgrades).
- GitOps is split into:
  - **install apps** (CRDs + controllers) in early sync waves
  - **resource apps** (CRs like `NodePool`, `Rollout`, `ClusterPolicy`, `ServiceMonitor`) in later waves
- Progressive delivery uses Argo Rollouts analysis queries. For a reliable validation path, the default recommendation is:
  - run a small **in-cluster Prometheus** for low-latency queries
  - optionally `remote_write` to **AMP** for central retention and dashboards
- EKS access should be explicit and auditable:
  - model platform/admin access via **EKS access entries + Kubernetes RBAC**
  - use Pod Identity / IRSA for controllers that touch AWS APIs
  - treat `enable_cluster_creator_admin_permissions` as bootstrap convenience, not the final steady state

## Prerequisites

- Terraform >= 1.6
- Helm >= 3.14
- kubectl >= 1.30
- AWS CLI v2
- yq, jq, kustomize
- An AWS account with quota approved for the instance families you intend to use
- EKS-compatible Ubuntu 24.04 GPU AMI strategy defined if you are not using Bottlerocket
- An existing DNS name for Argo CD and public ingress if you want external access on day one

## Quick start

```bash
make init
make bootstrap-argocd REPO_URL=https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git
make validate-manifests
```

## What is intentionally parameterized

A self-referencing GitOps repo cannot know its final GitHub URL before it exists. The repo therefore keeps the bootstrapping logic explicit and safe:

- `scripts/render_bootstrap.sh` renders self-referential GitOps artifacts under `rendered/` using `REPO_URL`:
  - root app (`rendered/platform-gitops/bootstrap/root-app.yaml`)
  - AppProjects (`rendered/platform-gitops/projects/`)
  - ApplicationSets (`rendered/platform-gitops/applicationsets/`)
- `scripts/bootstrap_argocd.sh` installs Argo CD and applies the rendered root app
- `terraform.tfvars` defines environment-specific values such as VPC CIDR, cluster name, domain, and workspace names
- AWS account and region stay external by design

That is not a scaffold shortcut. It is the cleanest way to avoid baking account-specific values into a production repository before the repository exists.

## Validation mindset

A repo like this should never be treated as “done” only because Terraform applied.

You should expect to validate:

- EKS health
- Argo CD root app health
- GPU resources visible on GPU nodes
- canary rollback path
- Pod Identity / IRSA behavior
- network policy default-deny behavior
- DCGM metrics flowing
- Kubecost allocation labels present
- training checkpoint recovery

See `docs/runbooks/` and `docs/deployment-order.md` for the operational flow.
