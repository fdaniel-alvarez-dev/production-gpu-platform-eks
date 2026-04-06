# Runbook — GPU XID error

1. Identify the node from DCGM metrics.
2. Check whether the error is transient or recurring.
3. Drain the node if the code indicates hardware instability.
4. Confirm whether the workload was inference or training.
5. If training was on Spot, verify checkpoint freshness before rescheduling.
6. Preserve evidence in the incident record.
