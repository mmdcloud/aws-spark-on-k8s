variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the dev EKS cluster"
  type        = string
  default     = "spark-eks-dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnets CIDR blocks"
  type        = list(string)
  default     = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets CIDR blocks"
  type        = list(string)
  default     = ["10.10.64.0/18", "10.10.128.0/18", "10.10.192.0/18"]
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.31"
}

variable "system_node_group_desired_size" {
  description = "Desired number of system nodes"
  type        = number
  default     = 2
}

variable "system_node_group_min_size" {
  description = "Minimum number of system nodes"
  type        = number
  default     = 1
}

variable "system_node_group_max_size" {
  description = "Maximum number of system nodes"
  type        = number
  default     = 4
}

variable "system_node_group_instance_types" {
  description = "Instance types for system nodes"
  type        = list(string)
  default     = ["m5.large"]
}

variable "executor_instance_families" {
  description = "Allowed instance families for Spark executors"
  type        = list(string)
  default     = ["r5", "m5", "r5d", "m5d"]
}

variable "driver_instance_families" {
  description = "Allowed instance families for Spark drivers"
  type        = list(string)
  default     = ["m5", "m5a"]
}

variable "executor_cpu_limit" {
  description = "Maximum total vCPUs Karpenter can provision for Spark executors"
  type        = string
  default     = "100"
}

variable "executor_memory_limit" {
  description = "Maximum total Memory Karpenter can provision for Spark executors"
  type        = string
  default     = "400Gi"
}

variable "event_log_retention_days" {
  description = "Spark event log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags applied to all dev resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Platform    = "spark-on-k8s"
  }
}
