# ==============================================================================
# Spark History Server Kubernetes Deployment
# ==============================================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "spark-history-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.spark_history_server_role_arn
    }
    labels = {
      "app.kubernetes.io/name" = "spark-history-server"
    }
  }
}

resource "kubernetes_config_map" "spark_defaults" {
  metadata {
    name      = "spark-history-server-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "spark-defaults.conf" = <<-EOF
      spark.history.fs.logDirectory                  s3a://${var.s3_event_log_bucket}/${var.s3_event_log_prefix}
      spark.history.ui.port                          18080
      spark.hadoop.fs.s3a.impl                       org.apache.hadoop.fs.s3a.S3AFileSystem
      spark.hadoop.fs.s3a.aws.credentials.provider   com.amazonaws.auth.WebIdentityTokenCredentialsProvider
      spark.history.fs.cleaner.enabled               true
      spark.history.fs.cleaner.maxAge                30d
      spark.history.retainedApplications             500
      spark.history.fs.update.interval               10s
    EOF
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = "spark-history-server"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "spark-history-server"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "spark-history-server"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "spark-history-server"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.this.metadata[0].name

        node_selector = {
          role = "system"
        }

        tolerations {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        container {
          name  = "spark-history-server"
          image = var.spark_image
          command = [
            "/opt/spark/bin/spark-class",
            "org.apache.spark.deploy.history.HistoryServer"
          ]

          port {
            container_port = 18080
            name           = "http"
          }

          resources {
            requests = {
              cpu    = var.resources.requests.cpu
              memory = var.resources.requests.memory
            }
            limits = {
              cpu    = var.resources.limits.cpu
              memory = var.resources.limits.memory
            }
          }

          volume_mount {
            name       = "spark-defaults"
            mount_path = "/opt/spark/conf/spark-defaults.conf"
            sub_path   = "spark-defaults.conf"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 18080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 18080
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }

        volume {
          name = "spark-defaults"
          config_map {
            name = kubernetes_config_map.spark_defaults.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.spark_defaults,
    kubernetes_service_account.this
  ]
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "spark-history-server"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "spark-history-server"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "spark-history-server"
    }

    port {
      port        = 18080
      target_port = 18080
      name        = "http"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "this" {
  count = var.ingress_enabled ? 1 : 0

  metadata {
    name      = "spark-history-server-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.this.metadata[0].name
              port {
                number = 18080
              }
            }
          }
        }
      }
    }
  }
}
