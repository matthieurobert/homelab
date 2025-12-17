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

resource "proxmox_virtual_environment_role" "csi" {
  role_id = "csi"

  privileges = [
    "Sys.Audit",
    "VM.Audit",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit",
  ]
}

resource "proxmox_virtual_environment_user" "kubernetes-csi" {
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.csi.role_id
  }

  comment  = "Managed by Terraform"
  user_id  = "kubernetes-csi@pve"
}

resource "proxmox_virtual_environment_user_token" "csi" {
  comment         = "Managed by Terraform"
  token_name      = "csi"
  user_id         = proxmox_virtual_environment_user.kubernetes-csi.user_id

  privileges_separation = false
}