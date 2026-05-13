###############################################################
# modules/eks/main.tf — EKS cluster + Kubernetes workloads
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_eks_cluster" "main" {
  name     = "${local.prefix}-cluster"
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = { Name = "${local.prefix}-cluster" }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.prefix}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  tags = { Name = "${local.prefix}-node-group" }
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_instances" "eks_workers" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [aws_eks_cluster.main.name]
  }
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.main.node_group_name]
  }
}

