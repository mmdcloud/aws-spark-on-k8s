# ==============================================================================
# Production Environment: Complete Spark on AWS EKS Platform
# ==============================================================================

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# 1. Multi-AZ VPC with Dedicated Endpoints
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  cluster_name               = var.cluster_name
  environment                = var.environment
  vpc_cidr                   = var.vpc_cidr
  availability_zones         = var.availability_zones
  public_subnet_cidrs        = var.public_subnet_cidrs
  private_subnet_cidrs       = var.private_subnet_cidrs
  single_nat_gateway         = false # High availability: Multi-AZ NAT Gateways
  enable_vpc_flow_logs       = true
  enable_interface_endpoints = true
  tags                       = var.tags
}

# ------------------------------------------------------------------------------
# 2. Production EKS Cluster (Control plane, Addons, System Node Group)
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name                     = var.cluster_name
  cluster_version                  = var.cluster_version
  environment                      = var.environment
  vpc_id                           = module.vpc.vpc_id
  private_subnet_ids               = module.vpc.private_subnet_ids
  endpoint_private_access          = true
  endpoint_public_access           = true
  system_node_group_desired_size   = var.system_node_group_desired_size
  system_node_group_min_size       = var.system_node_group_min_size
  system_node_group_max_size       = var.system_node_group_max_size
  system_node_group_instance_types = var.system_node_group_instance_types
  enable_prefix_delegation         = true
  tags                             = var.tags
}

# ------------------------------------------------------------------------------
# Kubernetes & Helm Providers configured with EKS credentials
# ------------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# ------------------------------------------------------------------------------
# 3. Dedicated S3 Storage & KMS for Spark Data & Event Logs
# ------------------------------------------------------------------------------
module "s3_spark" {
  source = "../../modules/s3_spark"

  cluster_name             = var.cluster_name
  environment              = var.environment
  event_log_retention_days = var.event_log_retention_days
  enable_versioning        = true
  tags                     = var.tags
}

# ------------------------------------------------------------------------------
# 4. Least-Privilege IAM IRSA for Spark Drivers, Executors & History Server
# ------------------------------------------------------------------------------
module "iam_spark_irsa" {
  source = "../../modules/iam_spark_irsa"

  cluster_name               = var.cluster_name
  oidc_provider_arn          = module.eks.oidc_provider_arn
  oidc_provider_url          = module.eks.oidc_provider_url
  spark_namespaces           = ["spark-apps", "default"]
  s3_data_bucket_arn         = module.s3_spark.data_bucket_arn
  s3_event_log_bucket_arn    = module.s3_spark.event_log_bucket_arn
  s3_kms_key_arn             = module.s3_spark.kms_key_arn
  enable_glue_catalog_access = true
  tags                       = var.tags
}

# ------------------------------------------------------------------------------
# 5. Karpenter Autoscaler with Driver (On-Demand) & Executor (Spot/NVMe) NodePools
# ------------------------------------------------------------------------------
module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name                      = module.eks.cluster_name
  cluster_endpoint                  = module.eks.cluster_endpoint
  oidc_provider_arn                 = module.eks.oidc_provider_arn
  oidc_provider_url                 = module.eks.oidc_provider_url
  node_security_group_id            = module.eks.node_security_group_id
  driver_instance_families          = var.driver_instance_families
  executor_instance_families        = var.executor_instance_families
  executor_cpu_limit                = var.executor_cpu_limit
  executor_memory_limit             = var.executor_memory_limit
  enable_spot_interruption_handling = true
  environment                       = var.environment
  tags                              = var.tags

  depends_on = [module.eks]
}

# ------------------------------------------------------------------------------
# 6. Spark Operator Controller & RBAC in Workload Namespaces
# ------------------------------------------------------------------------------
module "spark_operator" {
  source = "../../modules/spark_operator"

  cluster_name              = module.eks.cluster_name
  operator_namespace        = "spark-operator"
  spark_workload_namespaces = ["spark-apps"]
  spark_workload_role_arn   = module.iam_spark_irsa.spark_workload_role_arn
  enable_webhook            = true
  enable_metrics            = true
  tags                      = var.tags

  depends_on = [module.eks]
}

# ------------------------------------------------------------------------------
# 7. Spark History Server Web UI connected to S3 via IRSA
# ------------------------------------------------------------------------------
module "spark_history_server" {
  source = "../../modules/spark_history_server"

  cluster_name                  = module.eks.cluster_name
  namespace                     = "spark-history"
  service_account_name          = "spark-history-server"
  spark_history_server_role_arn = module.iam_spark_irsa.spark_history_server_role_arn
  s3_event_log_bucket           = module.s3_spark.event_log_bucket_name
  s3_event_log_prefix           = "spark-event-logs"
  replicas                      = 2
  ingress_enabled               = false
  tags                          = var.tags

  depends_on = [module.eks, module.iam_spark_irsa, module.s3_spark]
}
