# Deployment Order

This repository is intentionally ordered so you do not bootstrap the platform by luck.

## Phase 0 — Environment values

Before touching Terraform or Argo CD, define:

- AWS account and region
- cluster name
- route53 hosted zone or ingress domain
- CIDR plan
- repository URL
- KMS key strategy
- GPU instance families allowed by quota

## Phase 1 — Foundation AWS

Apply:

```bash
terraform -chdir=infra/terraform/live/prod init
terraform -chdir=infra/terraform/live/prod plan -var-file=terraform.tfvars
terraform -chdir=infra/terraform/live/prod apply -var-file=terraform.tfvars
```

Validate:
- VPC
- subnets
- NAT
- endpoints
- S3
- EFS
- EKS control plane
- general node group
- ECR repositories

## Phase 2 — Render bootstrap

```bash
REPO_URL=https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git ./scripts/render_bootstrap.sh
```

This creates rendered files under `rendered/` so the GitOps repo can point back to itself safely.

## Phase 3 — Bootstrap Argo CD

```bash
./scripts/bootstrap_argocd.sh
```

Validate:
- `argocd` namespace exists
- Argo CD pods are healthy
- root app is healthy
- AppProjects exist
- ApplicationSets render applications

## Phase 4 — GPU and cluster add-ons

Argo CD should then deploy, in order:
- gpu-operator
- karpenter
- storage-primitives
- argo-rollouts
- monitoring
- security
- training-platform
- inference-gateway
- cost
- tenancy

## Phase 5 — Functional validation

Run:

```bash
make validate-manifests
./scripts/smoke_inference.sh
./scripts/smoke_training.sh
```

Then validate:
- GPU allocatable visible
- DCGM metrics visible
- inference rollout works
- training checkpoints land in S3
- network policies do not break DNS/metrics
- cost labels appear in Kubecost

## Phase 6 — Production readiness

Do not call this done until the acceptance criteria in `docs/runbooks/go_live_checklist.md` are satisfied.
