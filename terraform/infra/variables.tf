variable "proxmox_host" {
  type = string
}

variable "state_host" {
  type = string
}

variable "github_user" {
  type = string
  default = " matthieurobert"
}

variable "project_name" {
  type = string
  default = "kome"
}

variable "datastore_id" {
  type = string
  default = "local"
}

variable "pve_vm_datastore_id" {
  type = string
  default = "local-lvm"
}

variable "pve_instances" {
  type = list(object({
    name = string
    node = string
    tags = list(string)
    cpu = number
    memory = number
    disk = number
    ipv4 = string
    ipv6 = string
  }))  
  default = [
    {
      name = "kome-1"
      node = "pve2"
      tags = [ "kome" ,"kubernetes", "terraform" ]
      cpu = 4
      memory = 12288
      disk = 100
      ipv4 = "dhcp"
      ipv6 = "dhcp"
    },
  ]
}
