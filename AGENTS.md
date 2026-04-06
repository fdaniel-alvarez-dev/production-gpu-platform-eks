# AGENTS.md

This repository is built for Codex CLI and human operators who need production-grade changes without hand-wavy shortcuts.

## Mission

Keep this repository deployable, reviewable, and production-safe.

Changes must strengthen:

- reliability
- security
- cost discipline
- operational clarity
- GitOps consistency
- human readability

## Working style

1. Read before you change.
   - Start with `README.md`
   - Then read `docs/deployment-order.md`
   - Then read the target area under `infra/terraform/`, `platform-gitops/`, or `platform-apps/`

2. Respect phase order.
   - Foundation before cluster add-ons
   - Cluster add-ons before workload apps
   - GPU enablement before GPU workloads
   - Observability and security before declaring anything production-ready

3. Prefer small, surgical changes.
   - Avoid sweeping edits across unrelated areas.
   - If a change crosses boundaries, explain why in the commit message and in the PR body.

4. Keep comments human.
   - Comments should read like something an experienced engineer would actually write during a production review.
   - Avoid filler, hype, and textbook noise.

5. Never hide trade-offs.
   - If a change improves one dimension but costs another, document it clearly.

## Non-negotiable repository rules

- Do not introduce manual-only operational steps when the change can be expressed declaratively.
- Do not add `latest` image tags in production manifests.
- Do not remove labels, taints, or policy guards without documenting the blast radius.
- Do not weaken security policy just to make a demo work.
- Do not mix inference and training pools.
- Do not bypass Argo CD by recommending `kubectl apply` as the steady-state method.

## Terraform standards

- Run `terraform fmt -recursive`
- Keep modules focused and composable
- Prefer explicit variables and outputs over magic locals
- Document assumptions in module `README.md` if complexity grows
- Use `for_each` and maps where it improves clarity, not to look clever
- Keep provider configuration environment-local, not module-local

## Kubernetes and GitOps standards

- All YAML must be valid and kustomize-friendly
- Every manifest should have a clear owner and purpose
- Namespaces, labels, and annotations must be intentional
- Argo CD projects must reflect ownership boundaries
- Sync waves must stay aligned with CRD/operator dependencies

## GPU platform standards

- GPU Operator is the production default unless there is a documented reason not to use it
- MIG is opt-in, not default
- Training must assume checkpoint recovery if Spot is enabled
- Inference must optimize for stable latency before aggressive cost reduction
- DCGM metrics must remain available if a change touches GPU scheduling or rollouts

## Validation commands

Run these before claiming success:

```bash
make fmt
make validate-terraform
make validate-manifests
make validate-python
```

If the change touches bootstrap logic:

```bash
make render-bootstrap REPO_URL=https://github.com/fdaniel-alvarez-dev/production-gpu-platform-eks.git
```

If the change touches application images:

```bash
make build-inference-image
make build-training-image
```

## What Codex should produce

When editing this repo, Codex should:

- preserve structure
- preserve deployment order
- explain trade-offs briefly in code comments where needed
- generate complete files, not half-finished stubs
- avoid TODOs unless they are paired with a concrete reason and owner

## Preferred output style

- Human English
- Clear names
- Short comments with operational meaning
- No inflated wording
- No generic AI phrasing

## Red flags

Stop and rethink if you are about to:

- add placeholders without an accompanying render/bootstrap path
- create circular dependencies between Argo apps
- push GPU workloads before the GPU stack is ready
- recommend Spot for user-facing inference by default
- install security policies in full enforce mode on day one without staged rollout

## Definition of done for changes

A change is only done when:

- syntax is correct
- file placement matches the repo model
- validation commands pass locally
- the change fits the deployment order
- the blast radius is understandable
- the README or docs are updated if operator behavior changed
