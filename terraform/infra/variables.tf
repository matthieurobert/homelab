variable "proxmox_host_1" {
  type = string
  default = "192.168.1.50"
}

variable "proxmox_host_2" {
  type = string
  default = "192.168.1.99"
}

variable "state_host" {
  type = string
  default = ""
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
  default = "zfs"
}

variable "pve2_vm_datastore_id" {
  type = string
  default = "samsung-ssds"
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
      node = "pve"
      tags = [ "kome" ,"kubernetes", "terraform" ]
      cpu = 4
      memory = 8192
      disk = 100
      ipv4 = "dhcp"
      ipv6 = "dhcp"
    },
  ]
}

variable "pve2_instances" {
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
      name = "kome-2"
      node = "pve2"
      tags = [ "kome" ,"kubernetes", "terraform" ]
      cpu = 4
      memory = 8192
      disk = 100
      ipv4 = "dhcp"
      ipv6 = "dhcp"
    }
  ]
}
