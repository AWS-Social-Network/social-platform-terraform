locals {
  prefix = "${var.project}-${var.environment}"
  services = [
    { name = "auth-service", node_port = 30080 },
    { name = "post-service", node_port = 30081 },
    { name = "feed-service", node_port = 30082 },
  ]
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = var.cluster_auth_token
  # insecure               = true
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
