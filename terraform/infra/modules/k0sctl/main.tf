resource "k0sctl_config" "k0sctl" {
  metadata {
    name = var.project_name
  }
  spec {
    dynamic "host" {
      for_each = var.instances
      content {
        role = host.value.k8s_role
        hostname = host.value.name
        no_taints = host.value.k8s_role == "controller+worker" ? true : false
        ssh {
          address = host.value.ip
          user = host.value.username
          key_path = "~/.ssh/id_rsa"
          port = 22
        }
      }
    }

    k0s {
      version = "v1.31.2+k0s.0"
      config = yamlencode({
        apiVersion = "k0s.k0sproject.io/v1beta1"
        kind = "ClusterConfig"
        metadata = {
          name = var.project_name
        }
        spec = {
          network = {
            provider = "custom"
            kubeProxy = {
              disabled = true
            }
          }
          telemetry = {
            enabled = false
          }
          extensions = {
            helm = {
              repositories = [{
                name = "argocd"
                url = "https://argoproj.github.io/argo-helm"
              }, {
                name = "cilium"
                url = "https://helm.cilium.io/"
              }]
              charts = [{
                name = "argocd"
                chartname = "argocd/argo-cd"
                version = "7.7.16"
                namespace = "argocd"
              },
              {
                name = "cilium"
                chartname = "cilium/cilium"
                version = "1.18.2"
                namespace = "kube-system"
                values = <<EOT
                  kubeProxyReplacement: true
                  k8sServiceHost: "${var.instances[0].ip}"
                  k8sServicePort: 6443
                EOT
              }]
            }
          }
        }
      })
    }
  }
}