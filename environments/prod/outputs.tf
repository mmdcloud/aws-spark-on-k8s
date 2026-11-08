output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint URL"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID where the Spark infrastructure is deployed"
  value       = module.vpc.vpc_id
}

output "s3_data_bucket" {
  description = "S3 bucket for Spark data and checkpoints"
  value       = module.s3_spark.data_bucket_name
}

output "s3_event_log_bucket" {
  description = "S3 bucket for Spark event logs"
  value       = module.s3_spark.event_log_bucket_name
}

output "spark_workload_role_arn" {
  description = "IAM IRSA Role ARN used by Spark applications"
  value       = module.iam_spark_irsa.spark_workload_role_arn
}

output "spark_history_server_role_arn" {
  description = "IAM IRSA Role ARN used by Spark History Server"
  value       = module.iam_spark_irsa.spark_history_server_role_arn
}

output "spark_operator_namespace" {
  description = "Namespace where Spark Operator is running"
  value       = module.spark_operator.operator_namespace
}

output "configure_kubectl_command" {
  description = "Command to configure kubectl context"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}
