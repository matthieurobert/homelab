output "kubeconfig" {
  value = module.k0sctl.kubeconfig
  sensitive = true
}

output "csi-token" {
  value = proxmox_virtual_environment_user_token.csi.value
  sensitive = true
}