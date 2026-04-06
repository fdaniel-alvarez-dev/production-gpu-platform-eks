# Runbook — Inference canary rollback

1. Compare canary and stable metrics.
2. Confirm whether the issue is warm-up noise or a real regression.
3. If the canary violates the thresholds, halt promotion.
4. Roll back to the previous stable revision.
5. Capture the image digest, model version, and metrics snapshot.
