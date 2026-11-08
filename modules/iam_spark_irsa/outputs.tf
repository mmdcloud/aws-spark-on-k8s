output "spark_workload_role_arn" {
  description = "ARN of the IAM role for Spark driver and executor pods"
  value       = aws_iam_role.spark_workload.arn
}

output "spark_workload_role_name" {
  description = "Name of the IAM role for Spark driver and executor pods"
  value       = aws_iam_role.spark_workload.name
}

output "spark_history_server_role_arn" {
  description = "ARN of the IAM role for the Spark History Server"
  value       = aws_iam_role.spark_history_server.arn
}

output "spark_history_server_role_name" {
  description = "Name of the IAM role for the Spark History Server"
  value       = aws_iam_role.spark_history_server.name
}
