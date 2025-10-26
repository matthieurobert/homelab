output "kubeconfig" {
  value = module.k0sctl.kubeconfig
  sensitive = true
}