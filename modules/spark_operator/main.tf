# ==============================================================================
# Spark Operator Helm Deployment
# ==============================================================================

resource "kubernetes_namespace" "operator" {
  metadata {
    name = var.operator_namespace
    labels = {
      "app.kubernetes.io/name"       = "spark-operator"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "spark_operator" {
  name             = "spark-operator"
  repository       = "https://kubeflow.github.io/spark-operator"
  chart            = "spark-operator"
  version          = var.spark_operator_version
  namespace        = kubernetes_namespace.operator.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      webhook = {
        enable = var.enable_webhook
        port   = 9443
      }
      metrics = {
        enable = var.enable_metrics
        port   = 10254
      }
      nodeSelector = {
        role = "system"
      }
      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
      ]
      resources = {
        limits = {
          cpu    = "500m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
      spark = {
        jobNamespaces = var.spark_workload_namespaces
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.operator
  ]
}
