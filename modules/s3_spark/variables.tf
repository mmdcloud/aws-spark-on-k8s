variable "cluster_name" {
  description = "Cluster name used for prefixing resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "event_log_bucket_name" {
  description = "Explicit name for the Spark event log S3 bucket. If empty, a default patterned name will be used"
  type        = string
  default     = ""
}

variable "data_bucket_name" {
  description = "Explicit name for the Spark warehouse/data S3 bucket. If empty, a default patterned name will be used"
  type        = string
  default     = ""
}

variable "event_log_retention_days" {
  description = "Number of days before Spark event logs are automatically deleted via S3 lifecycle"
  type        = number
  default     = 60
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
