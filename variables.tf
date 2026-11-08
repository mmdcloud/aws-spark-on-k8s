variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "spark-on-eks"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
}

variable "cluster_version" {
  description = "EKS Kubernetes Version"
  type        = string
  default     = "1.31"
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (true for cost savings, false for HA production multi-AZ)"
  type        = bool
  default     = false
}

variable "system_node_group_desired_size" {
  description = "Desired number of system nodes"
  type        = number
  default     = 3
}

variable "system_node_group_min_size" {
  description = "Minimum number of system nodes"
  type        = number
  default     = 2
}

variable "system_node_group_max_size" {
  description = "Maximum number of system nodes"
  type        = number
  default     = 8
}

variable "system_node_group_instance_types" {
  description = "Instance types for system nodes"
  type        = list(string)
  default     = ["m6i.xlarge", "m5.xlarge"]
}

variable "executor_instance_families" {
  description = "Allowed instance families for Spark executors (supports NVMe storage instances)"
  type        = list(string)
  default     = ["r5d", "r6id", "r5", "r6i", "m5d", "m6id", "c5d"]
}

variable "driver_instance_families" {
  description = "Allowed instance families for Spark drivers"
  type        = list(string)
  default     = ["m5", "m6i", "r5", "r6i"]
}

variable "executor_cpu_limit" {
  description = "Maximum total vCPUs Karpenter can provision for Spark executors"
  type        = string
  default     = "1000"
}

variable "executor_memory_limit" {
  description = "Maximum total Memory Karpenter can provision for Spark executors"
  type        = string
  default     = "4000Gi"
}

variable "event_log_retention_days" {
  description = "Spark event log retention in days"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Platform  = "spark-on-k8s"
  }
}
