variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "spark_operator_version" {
  description = "Helm chart version for spark-operator"
  type        = string
  default     = "2.1.2"
}

variable "operator_namespace" {
  description = "Kubernetes namespace where spark-operator controller runs"
  type        = string
  default     = "spark-operator"
}

variable "spark_workload_namespaces" {
  description = "List of Kubernetes namespaces where Spark jobs will execute"
  type        = list(string)
  default     = ["spark-apps"]
}

variable "spark_workload_role_arn" {
  description = "IAM IRSA Role ARN to annotate on the Spark workload service account"
  type        = string
}

variable "enable_webhook" {
  description = "Enable mutating admission webhook for spark-operator"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable Prometheus metrics exporter in spark-operator"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
