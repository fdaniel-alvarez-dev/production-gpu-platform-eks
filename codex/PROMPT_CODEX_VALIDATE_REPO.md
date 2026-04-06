# Codex CLI Prompt — Validate the Production GPU Platform Repo

You are acting as a senior platform engineer reviewing a production-grade AWS GPU platform repository.

## Goal

Validate that this repository is internally coherent, operationally safe, and aligned with a client-facing Senior DevOps role that expects:

- AWS infrastructure depth
- Kubernetes platform maturity
- Terraform fluency
- CI/CD ownership
- GPU workload awareness
- observability, security, and cost control
- strong judgment under ambiguity

## Scope of validation

Check the repository end to end:

1. Terraform
   - module boundaries
   - provider placement
   - variable hygiene
   - outputs
   - formatting
   - obvious dependency mistakes

2. GitOps bootstrap
   - AppProjects
   - ApplicationSets
   - sync waves
   - root app wiring
   - namespace ownership

3. GPU platform
   - GPU Operator placement
   - Karpenter node classes and node pools
   - separation of general / inference / training
   - taints, tolerations, labels, node selectors

4. Progressive delivery
   - Rollouts wiring
   - metrics-based gates
   - rollback safety

5. Observability
   - AMP / AMG integration points
   - DCGM exporter assumptions
   - dashboards / alert rules placement

6. Security
   - Pod Identity / IRSA fallback
   - Kyverno policies staged correctly
   - network policy defaults
   - image verification

7. FinOps
   - Kubecost placement
   - tagging assumptions
   - spot strategy
   - schedule strategy

8. Team workflow
   - namespaces
   - RBAC boundaries
   - quotas
   - auditability

## What to do

- Read the whole repository before suggesting changes.
- Find broken assumptions, missing dependencies, naming mismatches, unsafe defaults, and weak spots.
- Be precise.
- Do not give generic advice.
- Prefer changes that improve production-readiness without bloating the design.
- Keep comments and suggestions in natural English.

## Output format

Return these sections:

### 1. Executive summary
- Is the repo structurally strong or not?
- What would worry a senior reviewer first?

### 2. Critical blockers
- Anything that would likely break bootstrap or deployment

### 3. High-risk weaknesses
- Anything that may not fail immediately but is dangerous in production

### 4. Good signals
- What clearly reflects senior DevOps judgment

### 5. Exact fixes
- File-by-file corrections with concrete edits

### 6. Final verdict
- Would this repo strengthen a senior DevOps application for GPU-heavy infrastructure work?

## Validation commands to run

```bash
make fmt
make validate-terraform
make validate-manifests
make validate-python
```

If bootstrap rendering is involved:

```bash
make render-bootstrap REPO_URL=https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git
```

## Ground rules

- Do not simplify by deleting important production controls.
- Do not replace intentional AWS-first design with vague multi-cloud slogans.
- Do not recommend “just do it manually” as the main path.
- Treat this like a real client-facing infrastructure repository.
