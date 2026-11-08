output "operator_namespace" {
  description = "The namespace where Spark Operator is deployed"
  value       = kubernetes_namespace.operator.metadata[0].name
}

output "spark_workload_namespaces" {
  description = "The namespaces configured for running Spark workloads"
  value       = [for ns in kubernetes_namespace.spark_workload : ns.metadata[0].name]
}

output "spark_service_account_names" {
  description = "The service account names created for Spark jobs"
  value       = [for sa in kubernetes_service_account.spark_sa : sa.metadata[0].name]
}
