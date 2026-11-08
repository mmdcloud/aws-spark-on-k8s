variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC Provider (without https://)"
  type        = string
}

variable "spark_namespaces" {
  description = "List of Kubernetes namespaces where Spark jobs run"
  type        = list(string)
  default     = ["spark-apps", "default"]
}

variable "spark_service_account_names" {
  description = "List of Kubernetes Service Account names used by Spark drivers and executors"
  type        = list(string)
  default     = ["spark-sa", "spark-driver", "spark-executor"]
}

variable "history_server_namespace" {
  description = "Kubernetes namespace where Spark History Server is deployed"
  type        = string
  default     = "spark-history"
}

variable "history_server_service_account_name" {
  description = "Kubernetes Service Account name for Spark History Server"
  type        = string
  default     = "spark-history-server"
}

variable "s3_event_log_bucket_arn" {
  description = "ARN of the S3 bucket storing Spark event logs"
  type        = string
}

variable "s3_data_bucket_arn" {
  description = "ARN of the S3 bucket storing Spark data and checkpoints"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN of the KMS Key used for Spark S3 encryption"
  type        = string
}

variable "enable_glue_catalog_access" {
  description = "Grant Spark jobs read/write access to AWS Glue Data Catalog (Hive/Iceberg metastore)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
