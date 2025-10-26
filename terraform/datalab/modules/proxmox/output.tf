output "instances_ip" {
  value = [ for vm in proxmox_virtual_environment_vm.vm : vm.ipv4_addresses[1][0] ]
}