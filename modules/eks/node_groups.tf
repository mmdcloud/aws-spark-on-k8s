# ==============================================================================
# EKS Managed Node Group (System Workloads)
# ==============================================================================

# Node Group IAM Role
resource "aws_iam_role" "system_node" {
  name = "${var.cluster_name}-system-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "system_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.system_node.name
}

resource "aws_iam_role_policy_attachment" "system_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.system_node.name
}

resource "aws_iam_role_policy_attachment" "system_node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.system_node.name
}

resource "aws_iam_role_policy_attachment" "system_node_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.system_node.name
}

# System Managed Node Group
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-system-ng"
  node_role_arn   = aws_iam_role.system_node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.system_node_group_instance_types
  capacity_type   = "ON_DEMAND"
  disk_size       = var.system_node_group_disk_size

  scaling_config {
    desired_size = var.system_node_group_desired_size
    max_size     = var.system_node_group_max_size
    min_size     = var.system_node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role        = "system"
    workload    = "core-infra"
    Environment = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-system-node"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.system_node_worker,
    aws_iam_role_policy_attachment.system_node_cni,
    aws_iam_role_policy_attachment.system_node_ecr,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}
