module "proxmox" {
  source = "./modules/proxmox"

  project_name = var.project_name
  vm_datastore_id = var.pve_vm_datastore_id
  github_user = var.github_user
  instances = var.pve_instances
}

module "k0sctl" {
  depends_on = [ module.proxmox ]
  source = "./modules/k0sctl"

  project_name = var.project_name
  instances = [
    for key, instance in var.pve_instances :
    {
      name = instance.name
      k8s_role = "controller+worker"
      username = "ubuntu"
      ip = module.proxmox.instances_ip[key]
    }
  ] 
}