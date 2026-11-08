output "karpenter_node_role_arn" {
  description = "ARN of the IAM role used by Karpenter EC2 worker nodes"
  value       = aws_iam_role.node.arn
}

output "karpenter_node_role_name" {
  description = "Name of the IAM role used by Karpenter EC2 worker nodes"
  value       = aws_iam_role.node.name
}

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role used by Karpenter Controller"
  value       = aws_iam_role.controller.arn
}

output "interruption_queue_arn" {
  description = "ARN of the SQS queue for Spot interruption notifications"
  value       = try(aws_sqs_queue.interruption[0].arn, "")
}

output "interruption_queue_name" {
  description = "Name of the SQS queue for Spot interruption notifications"
  value       = try(aws_sqs_queue.interruption[0].name, "")
}
