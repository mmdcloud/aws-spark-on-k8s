# ==============================================================================
# VPC Module: Endpoints for Spark & EKS
# ==============================================================================

# ------------------------------------------------------------------------------
# S3 Gateway Endpoint (ESSENTIAL FOR SPARK: Free, zero NAT data-transfer cost,
# direct line-rate throughput to S3 data lakes and event logs)
# ------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private[*].id, [aws_route_table.public.id])

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-s3-endpoint"
      Environment = var.environment
    }
  )
}

# DynamoDB Gateway Endpoint (For S3A committers using DynamoDB metadata locks)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-dynamodb-endpoint"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# Interface Endpoints (ECR, STS, CloudWatch Logs)
# ------------------------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_interface_endpoints ? 1 : 0
  name        = "${var.cluster_name}-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-vpc-endpoints-sg"
      Environment = var.environment
    }
  )
}

locals {
  interface_services = var.enable_interface_endpoints ? toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "sts"
  ]) : toset([])
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_services
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${replace(each.value, ".", "-")}-endpoint"
      Environment = var.environment
    }
  )
}
