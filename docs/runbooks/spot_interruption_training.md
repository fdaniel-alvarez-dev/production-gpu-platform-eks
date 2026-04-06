# Runbook — Training Spot interruption

1. Confirm the interruption event.
2. Check the latest checkpoint in S3.
3. Verify the job is restart-safe.
4. Reschedule onto a new training node.
5. Confirm the resumed job loads the last checkpoint.
6. Record total recovery time and checkpoint age.
