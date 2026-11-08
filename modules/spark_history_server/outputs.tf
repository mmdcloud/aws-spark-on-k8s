output "service_name" {
  description = "Name of the Spark History Server Kubernetes service"
  value       = kubernetes_service.this.metadata[0].name
}

output "service_port" {
  description = "Port exposed by the Spark History Server service"
  value       = kubernetes_service.this.spec[0].port[0].port
}

output "namespace" {
  description = "Namespace where the Spark History Server is deployed"
  value       = kubernetes_namespace.this.metadata[0].name
}
