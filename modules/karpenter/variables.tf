variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN for Karpenter IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC Provider URL (without https://)"
  type        = string
}

variable "node_security_group_id" {
  description = "Security group ID attached to worker nodes"
  type        = string
}

variable "karpenter_version" {
  description = "Version of Karpenter Helm chart to deploy"
  type        = string
  default     = "1.0.8"
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace to deploy Karpenter"
  type        = string
  default     = "kube-system"
}

variable "enable_spot_interruption_handling" {
  description = "Enable SQS queue and EventBridge rules for Spot interruption handling"
  type        = bool
  default     = true
}

variable "executor_instance_families" {
  description = "Allowed instance families for Spark executors (supports memory-optimized & NVMe storage)"
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

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
