# Job alignment

This repository is intentionally aligned with the Senior DevOps Engineer role.

## Direct alignment points

- **AWS infrastructure**: foundation, EKS, ECR, IAM, managed observability
- **Kubernetes**: general, inference, and training pools with explicit GPU scheduling logic
- **Terraform**: production-oriented module and live environment layout
- **CI/CD**: repository validation workflow and Codex validation contract
- **GPU awareness**: GPU Operator, DCGM, GFD, node pool separation, training checkpoint assumptions
- **Client-facing trade-offs**: the docs and ADRs explain why certain choices are safer for production even when they cost more or take longer
- **Ambiguous environments**: the structure is ready for staged rollout and incremental hardening, not a brittle one-shot deployment

## Why this also signals systems-level maturity

Even though the target role is cloud-focused, the repository shows habits that also matter in performance-sensitive and embedded-like environments:

- hardware-aware scheduling
- deterministic rollout control
- failure-domain isolation
- strict operational sequencing
- safety-first rollback design
- observability tied to hardware behavior, not just application logs
