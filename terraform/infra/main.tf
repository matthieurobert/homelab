module "proxmox-1" {
  source = "./modules/proxmox"
  providers = {
    proxmox = proxmox.pve
  }
  project_name = var.project_name
  vm_datastore_id = var.pve_vm_datastore_id
  github_user = var.github_user
  instances = var.pve_instances
}

module "proxmox-2" {
  source = "./modules/proxmox"
  providers = {
    proxmox = proxmox.pve2
  }
  project_name = var.project_name
  vm_datastore_id = var.pve2_vm_datastore_id
  github_user = var.github_user
  instances = var.pve2_instances
}

module "k0sctl" {
  source = "./modules/k0sctl"
  project_name = var.project_name
  instances = concat(
    [
      for key, instance in var.pve_instances :
      {
        name = instance.name
        k8s_role = "controller+worker"
        username = "ubuntu"
        ip = module.proxmox-1.instances_ip[key]
      }
    ],
    [
      for key, instance in var.pve2_instances :
      {
        name = instance.name
        k8s_role = "worker"
        username = "ubuntu"
        ip = module.proxmox-2.instances_ip[key]
      }
    ]
  )
  
}