###############################################################
# modules/eks/main.tf
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_eks_cluster" "main" {
  name     = "${local.prefix}-cluster"
  role_arn = var.eks_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = { Name = "${local.prefix}-cluster" }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.prefix}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  tags = { Name = "${local.prefix}-node-group" }
}
