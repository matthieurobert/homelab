output "kubeconfig" {
  value = talos_cluster_kubeconfig.talab.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  value = talos_machine_configuration_apply.talab.machine_configuration
  sensitive = true
}

output "csi-password" {
  value     = proxmox_virtual_environment_user_token.csi.value
  sensitive = true
}