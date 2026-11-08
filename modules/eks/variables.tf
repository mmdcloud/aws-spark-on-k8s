variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where the cluster and nodes will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS control plane and worker nodes"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Number of days to retain EKS cluster logs in CloudWatch"
  type        = number
  default     = 30
}

variable "system_node_group_instance_types" {
  description = "Instance types for system node group (hosts controllers, operators, monitoring)"
  type        = list(string)
  default     = ["m6i.xlarge", "m5.xlarge"]
}

variable "system_node_group_min_size" {
  description = "Minimum size for system node group"
  type        = number
  default     = 2
}

variable "system_node_group_max_size" {
  description = "Maximum size for system node group"
  type        = number
  default     = 6
}

variable "system_node_group_desired_size" {
  description = "Desired size for system node group"
  type        = number
  default     = 2
}

variable "system_node_group_disk_size" {
  description = "Root disk size in GiB for system nodes"
  type        = number
  default     = 80
}

variable "enable_prefix_delegation" {
  description = "Enable VPC CNI prefix delegation to allow high pod density for Spark executors"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all EKS resources"
  type        = map(string)
  default     = {}
}
