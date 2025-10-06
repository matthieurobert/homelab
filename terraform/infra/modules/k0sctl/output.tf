output "kubeconfig" {
  value = k0sctl_config.k0sctl.kube_yaml
  sensitive = true
}

output "host" {
  value = k0sctl_config.k0sctl.kube_host
}