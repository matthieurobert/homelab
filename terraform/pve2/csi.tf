resource "proxmox_virtual_environment_role" "csi" {
  role_id = "csi"

  privileges = [
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