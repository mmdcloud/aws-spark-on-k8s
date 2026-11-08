output "event_log_bucket_name" {
  description = "The name of the Spark event logs S3 bucket"
  value       = aws_s3_bucket.event_logs.id
}

output "event_log_bucket_arn" {
  description = "The ARN of the Spark event logs S3 bucket"
  value       = aws_s3_bucket.event_logs.arn
}

output "data_bucket_name" {
  description = "The name of the Spark data/warehouse S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "data_bucket_arn" {
  description = "The ARN of the Spark data/warehouse S3 bucket"
  value       = aws_s3_bucket.data.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encrypting Spark S3 buckets"
  value       = aws_kms_key.spark_s3.arn
}

output "kms_key_id" {
  description = "The Key ID of the KMS key used for encrypting Spark S3 buckets"
  value       = aws_kms_key.spark_s3.key_id
}
