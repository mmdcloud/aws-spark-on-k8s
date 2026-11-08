# ==============================================================================
# Karpenter Spark NodePools & EC2NodeClass Deployment
# ==============================================================================

resource "helm_release" "spark_nodepools" {
  name      = "spark-nodepools"
  namespace = var.karpenter_namespace
  chart     = "${path.module}/charts/spark-nodepools"
  version   = "1.0.0"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      nodeRole    = aws_iam_role.node.name
      driver = {
        instanceFamilies = var.driver_instance_families
        capacityType     = ["on-demand"]
        cpuLimit         = "200"
        memoryLimit      = "800Gi"
      }
      executor = {
        instanceFamilies = var.executor_instance_families
        capacityType     = ["spot"]
        cpuLimit         = var.executor_cpu_limit
        memoryLimit      = var.executor_memory_limit
      }
    })
  ]

  depends_on = [
    helm_release.karpenter
  ]
}
