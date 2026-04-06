resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each                = { for idx, az in var.azs : az => var.public_subnet_cidrs[idx] }
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each          = { for idx, az in var.azs : az => var.private_subnet_cidrs[idx] }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-nat-${each.key}"
  })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.platform_name}-${var.environment}-nodes"
  description = "Baseline security group for EKS worker nodes"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-nodes-sg"
  })
}

resource "aws_s3_bucket" "models" {
  bucket = "${var.platform_name}-${var.environment}-models"
  tags   = merge(var.tags, { Name = "${var.platform_name}-${var.environment}-models" })
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "models" {
  bucket = aws_s3_bucket.models.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "models" {
  bucket                  = aws_s3_bucket.models.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "checkpoints" {
  bucket = "${var.platform_name}-${var.environment}-checkpoints"
  tags   = merge(var.tags, { Name = "${var.platform_name}-${var.environment}-checkpoints" })
}

resource "aws_s3_bucket_versioning" "checkpoints" {
  bucket = aws_s3_bucket.checkpoints.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "checkpoints" {
  bucket = aws_s3_bucket.checkpoints.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "checkpoints" {
  bucket                  = aws_s3_bucket.checkpoints.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_efs_file_system" "shared" {
  encrypted = true
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-efs"
  })
}

resource "aws_efs_mount_target" "this" {
  for_each        = aws_subnet.private
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.eks_nodes.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-vpce-s3"
  })
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(["ecr.api", "ecr.dkr", "sts", "logs", "secretsmanager"])
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.eks_nodes.id]
  private_dns_enabled = true
  tags = merge(var.tags, {
    Name = "${var.platform_name}-${var.environment}-vpce-${replace(each.value, ".", "-")}"
  })
}

data "aws_region" "current" {}
