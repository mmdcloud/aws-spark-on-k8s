# ==============================================================================
# IAM IRSA Module: Least-Privilege Roles for Spark Applications & History Server
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Spark Application IAM Role (Assumed by Drivers & Executors)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "spark_workload" {
  name = "${var.cluster_name}-spark-workload-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringLike = {
            "${var.oidc_provider_url}:sub" : [
              for ns in var.spark_namespaces : "system:serviceaccount:${ns}:*"
            ]
          }
          StringEquals = {
            "${var.oidc_provider_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# S3 Data Lake & Checkpoint Policy for Spark Applications
resource "aws_iam_policy" "spark_s3_access" {
  name        = "${var.cluster_name}-spark-s3-access-policy"
  description = "Allows Spark driver and executor pods read/write access to data buckets and event logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SparkDataBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "${var.s3_data_bucket_arn}/*"
        ]
      },
      {
        Sid    = "SparkDataBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_data_bucket_arn
        ]
      },
      {
        Sid    = "SparkEventLogBucketWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "${var.s3_event_log_bucket_arn}/*"
        ]
      },
      {
        Sid    = "SparkEventLogBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_event_log_bucket_arn
        ]
      },
      {
        Sid    = "KMSDecryptionAndEncryption"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          var.s3_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "spark_workload_s3" {
  policy_arn = aws_iam_policy.spark_s3_access.arn
  role       = aws_iam_role.spark_workload.name
}

# Optional AWS Glue Data Catalog Policy (for Metastore / Iceberg / Delta)
resource "aws_iam_policy" "spark_glue_access" {
  count       = var.enable_glue_catalog_access ? 1 : 0
  name        = "${var.cluster_name}-spark-glue-policy"
  description = "Allows Spark to read/write metadata in AWS Glue Data Catalog"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GlueCatalogAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:DeleteTable",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "glue:CreatePartition",
          "glue:BatchCreatePartition",
          "glue:UpdatePartition",
          "glue:DeletePartition",
          "glue:BatchDeletePartition"
        ]
        Resource = [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/*",
          "arn:aws:glue:*:*:table/*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "spark_workload_glue" {
  count      = var.enable_glue_catalog_access ? 1 : 0
  policy_arn = aws_iam_policy.spark_glue_access[0].arn
  role       = aws_iam_role.spark_workload.name
}

# ------------------------------------------------------------------------------
# 2. Spark History Server IAM Role (Read-only on Event Logs)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "spark_history_server" {
  name = "${var.cluster_name}-spark-history-server-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" : "system:serviceaccount:${var.history_server_namespace}:${var.history_server_service_account_name}",
            "${var.oidc_provider_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "spark_history_s3" {
  name        = "${var.cluster_name}-spark-history-s3-policy"
  description = "Allows Spark History Server to read event logs from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadEventLogs"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_event_log_bucket_arn,
          "${var.s3_event_log_bucket_arn}/*"
        ]
      },
      {
        Sid    = "KMSDecryptEventLogs"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          var.s3_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "spark_history_server_s3" {
  policy_arn = aws_iam_policy.spark_history_s3.arn
  role       = aws_iam_role.spark_history_server.name
}
