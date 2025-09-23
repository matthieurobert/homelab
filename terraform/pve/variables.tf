variable "proxmox_host" {
  type = string
  default = "pve"
}

variable "state_host" {
  type = string
  default = ""
}

variable "github_user" {
  type = string
  default = "foo"
}

variable "project_name" {
  type = string
  default = "docker"
}

variable "datastore_id" {
  type = string
  default = "local"
}

variable "vm_datastore_id" {
  type = string
  default = "zfs"
}

variable "docker_instance" {
  type = object({
    name = string
    node = string
    tags = list(string)
    cpu = number
    memory = number
    disk = number
    ipv4 = string
    ipv6 = string
  })
  default = {
      name = "docker"
      node = "pve"
      tags = [ "docker", "terraform" ]
      cpu = 2
      memory = 8192
      disk = 100
      ipv4 = "dhcp"
      ipv6 = "dhcp"
    }
}
