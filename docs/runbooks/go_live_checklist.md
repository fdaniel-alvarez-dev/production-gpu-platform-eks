# Go-Live Checklist

## Foundation
- [ ] VPC deployed in three AZs
- [ ] Private subnets have the expected egress path
- [ ] VPC endpoints reachable from worker subnets
- [ ] S3 buckets have encryption, versioning, and public access blocked
- [ ] EFS mount targets are healthy in all AZs

## Cluster
- [ ] EKS control plane healthy
- [ ] General node group healthy
- [ ] Karpenter controller healthy
- [ ] Inference and training pools create nodes as expected

## GPU
- [ ] GPU Operator healthy
- [ ] `nvidia.com/gpu` visible on GPU nodes
- [ ] DCGM Exporter scraping works
- [ ] GFD labels present

## GitOps
- [ ] Root app healthy
- [ ] ApplicationSets render expected applications
- [ ] Sync waves match dependency order
- [ ] No manual bootstrap artifacts remain undocumented

## Security
- [ ] Pod Identity or IRSA fallback works for a sample workload
- [ ] Kyverno policies are in the intended stage (audit / enforce)
- [ ] Default-deny network policy tested without breaking DNS and monitoring
- [ ] Image verification tested with an allowed and a denied image

## Observability
- [ ] AMP remote write active
- [ ] AMG dashboards load
- [ ] GPU metrics available
- [ ] Rollout metrics queries return useful data

## FinOps
- [ ] Kubecost shows namespace/team/workload labels
- [ ] Training Spot interruption path is documented and tested
- [ ] Non-production schedules behave as expected

## Workloads
- [ ] Inference canary can progress and roll back
- [ ] Training job writes checkpoints to S3
- [ ] Training recovery from checkpoint tested
