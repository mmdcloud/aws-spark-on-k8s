variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the Spark History Server"
  type        = string
  default     = "spark-history"
}

variable "service_account_name" {
  description = "Name of the Kubernetes Service Account for Spark History Server"
  type        = string
  default     = "spark-history-server"
}

variable "spark_history_server_role_arn" {
  description = "IAM IRSA Role ARN for Spark History Server"
  type        = string
}

variable "s3_event_log_bucket" {
  description = "Name of the S3 bucket where Spark event logs are stored"
  type        = string
}

variable "s3_event_log_prefix" {
  description = "S3 prefix/directory for Spark event logs"
  type        = string
  default     = "spark-event-logs"
}

variable "spark_image" {
  description = "Docker image for Spark History Server"
  type        = string
  default     = "apache/spark:3.5.3"
}

variable "replicas" {
  description = "Number of Spark History Server replicas"
  type        = number
  default     = 1
}

variable "ingress_enabled" {
  description = "Enable Kubernetes Ingress for Spark History Server Web UI"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Host domain for Spark History Server Ingress"
  type        = string
  default     = "spark-history.example.com"
}

variable "ingress_class_name" {
  description = "Ingress class name (e.g. alb)"
  type        = string
  default     = "alb"
}

variable "resources" {
  description = "Resource requests and limits for Spark History Server"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
