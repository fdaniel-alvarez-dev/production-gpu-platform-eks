output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = values(aws_subnet.private)[*].id }
output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "node_security_group_id" { value = aws_security_group.eks_nodes.id }
output "models_bucket_name" { value = aws_s3_bucket.models.bucket }
output "checkpoints_bucket_name" { value = aws_s3_bucket.checkpoints.bucket }
output "efs_file_system_id" { value = aws_efs_file_system.shared.id }
