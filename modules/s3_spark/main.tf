# ==============================================================================
# S3 Storage Module for Apache Spark on EKS
# ==============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  event_log_bucket = var.event_log_bucket_name != "" ? var.event_log_bucket_name : "${var.cluster_name}-spark-event-logs-${data.aws_caller_identity.current.account_id}"
  data_bucket      = var.data_bucket_name != "" ? var.data_bucket_name : "${var.cluster_name}-spark-data-${data.aws_caller_identity.current.account_id}"
}

# ------------------------------------------------------------------------------
# KMS Customer Managed Key for S3 Spark Data & Event Logs
# ------------------------------------------------------------------------------
resource "aws_kms_key" "spark_s3" {
  description             = "KMS Key for Spark S3 Storage (Data & Event Logs)"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3AndEKSWorkloads"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-spark-s3-kms"
      Environment = var.environment
    }
  )
}

resource "aws_kms_alias" "spark_s3" {
  name          = "alias/${var.cluster_name}-spark-s3"
  target_key_id = aws_kms_key.spark_s3.key_id
}

# ------------------------------------------------------------------------------
# 1. Spark Event Logs S3 Bucket (Spark History Server backend)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "event_logs" {
  bucket        = local.event_log_bucket
  force_destroy = var.environment == "dev" ? true : false

  tags = merge(
    var.tags,
    {
      Name        = local.event_log_bucket
      Purpose     = "spark-event-logs"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "event_logs" {
  bucket = aws_s3_bucket.event_logs.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "event_logs" {
  bucket = aws_s3_bucket.event_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.spark_s3.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "event_logs" {
  bucket = aws_s3_bucket.event_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "event_logs" {
  bucket = aws_s3_bucket.event_logs.id

  rule {
    id     = "expire-old-spark-event-logs"
    status = "Enabled"

    expiration {
      days = var.event_log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}

resource "aws_s3_bucket_policy" "event_logs_tls" {
  bucket = aws_s3_bucket.event_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.event_logs.arn,
          "${aws_s3_bucket.event_logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.event_logs]
}

# ------------------------------------------------------------------------------
# 2. Spark Data & Warehouse S3 Bucket
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket        = local.data_bucket
  force_destroy = var.environment == "dev" ? true : false

  tags = merge(
    var.tags,
    {
      Name        = local.data_bucket
      Purpose     = "spark-data-lake-checkpoints"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.spark_s3.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}

resource "aws_s3_bucket_policy" "data_tls" {
  bucket = aws_s3_bucket.data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.data]
}
