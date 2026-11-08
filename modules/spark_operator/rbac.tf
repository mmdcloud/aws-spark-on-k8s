# ==============================================================================
# Spark Workload Namespaces & RBAC
# Sets up ServiceAccounts with IRSA and permissions for Spark Drivers & Executors
# ==============================================================================

resource "kubernetes_namespace" "spark_workload" {
  for_each = toset(var.spark_workload_namespaces)

  metadata {
    name = each.value
    labels = {
      "app.kubernetes.io/part-of"    = "spark"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Service Account for Spark Application (Annotated with IRSA Role)
resource "kubernetes_service_account" "spark_sa" {
  for_each = toset(var.spark_workload_namespaces)

  metadata {
    name      = "spark-sa"
    namespace = kubernetes_namespace.spark_workload[each.value].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.spark_workload_role_arn
    }
    labels = {
      "app.kubernetes.io/name"       = "spark-sa"
      "app.kubernetes.io/part-of"    = "spark"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Role allowing Spark Driver to spawn executor pods and manage state
resource "kubernetes_role" "spark_driver" {
  for_each = toset(var.spark_workload_namespaces)

  metadata {
    name      = "spark-driver-role"
    namespace = kubernetes_namespace.spark_workload[each.value].metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "persistentvolumeclaims"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["*"]
  }
}

# RoleBinding connecting Service Account to Driver Role
resource "kubernetes_role_binding" "spark_driver" {
  for_each = toset(var.spark_workload_namespaces)

  metadata {
    name      = "spark-driver-rolebinding"
    namespace = kubernetes_namespace.spark_workload[each.value].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark_driver[each.value].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.spark_sa[each.value].metadata[0].name
    namespace = kubernetes_namespace.spark_workload[each.value].metadata[0].name
  }
}
