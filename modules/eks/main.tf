###############################################################
# modules/eks/main.tf — EKS cluster + Kubernetes workloads
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
  services = [
    { name = "auth-service"  , node_port = 30080 },
    { name = "post-service"  , node_port = 30081 },
    { name = "feed-service"  , node_port = 30082 },
  ]
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
  depends_on = [aws_eks_node_group.main]
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "social-app"
  }
}

resource "kubernetes_secret" "ghcr_pull_secret" {
  metadata {
    name      = "ghcr-pull-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = "AWS-Social-Network"
          password = var.ghcr_pat
          auth     = base64encode("AWS-Social-Network:${var.ghcr_pat}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.app]
}

resource "kubernetes_deployment" "services" {
  count = length(local.services)

  metadata {
    name      = local.services[count.index].name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = local.services[count.index].name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = local.services[count.index].name
      }
    }

    template {
      metadata {
        labels = {
          app = local.services[count.index].name
        }
      }

      spec {
        image_pull_secrets {                                                       
          name = kubernetes_secret.ghcr_pull_secret.metadata[0].name           
        }  
        container {
          name  = local.services[count.index].name
          image = "hashicorp/http-echo:0.2.3"
          args  = ["-text=${local.services[count.index].name}"]

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [aws_eks_node_group.main]
}

resource "kubernetes_service" "services" {
  count = length(local.services)

  metadata {
    name      = "${local.services[count.index].name}-svc"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = local.services[count.index].name
    }

    port {
      port        = 80
      target_port = 80
      node_port   = local.services[count.index].node_port
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.services]
}