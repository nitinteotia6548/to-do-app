resource "kubernetes_deployment" "to-do-app-deployment" {
  metadata {
    name = "to-do-app-deployment"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "to-do-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "to-do-app"
        }
      }

      spec {
        container {
          image = "keerthana2910/to-do-app:latest"
          name  = "to-do-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [
    aws_eks_node_group.tss-cluster-node-groups
  ]
}

resource "kubernetes_service" "to-do-app-service" {
  metadata {
    name = "to-do-app-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment.to-do-app-deployment.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
  depends_on = [
    kubernetes_deployment.to-do-app-deployment
  ]
}
