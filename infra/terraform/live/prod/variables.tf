variable "aws_region" {
  type        = string
  description = "AWS region for the production platform"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "prod"
}

variable "platform_name" {
  type        = string
  description = "Base name for the platform"
  default     = "gpu-platform"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the platform VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones used by the platform"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.30"
}

variable "general_instance_types" {
  type        = list(string)
  description = "Instance types for the baseline general node group"
  default     = ["m6i.large"]
}

variable "general_desired_size" {
  type    = number
  default = 3
}

variable "general_min_size" {
  type    = number
  default = 3
}

variable "general_max_size" {
  type    = number
  default = 6
}

variable "domain_name" {
  type        = string
  description = "Domain used for platform services like Argo CD"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}
