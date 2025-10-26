variable "proxmox_host" {
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
  default = "datalab"
}

variable "datastore_id" {
  type = string
  default = "local"
}

variable "pve_vm_datastore_id" {
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
      name = "datalab-1"
      node = "pve2"
      tags = [ "datalab" ,"kubernetes", "terraform" ]
      cpu = 4
      memory = 8192
      disk = 300
      ipv4 = "dhcp"
      ipv6 = "dhcp"
    },
  ]
}