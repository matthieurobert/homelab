variable "proxmox_host" {
  type = string
  default = "pve2"
}

variable "state_host" {
  type = string
  default = ""
}

variable "project_name" {
  type = string
  default = "talab"
}

variable "node_name" {
  type = string
  default = "pve2"
}

variable "datastore_id" {
  type = string
  default = "local"
}

variable "vm_datastore_id" {
  type = string
  default = "local-lvm"
}


variable "cpu_type" {
  type = string
  default = "x86-64-v2-AES" 
}

variable "gateway_ip" {
  type = string
  default = "192.168.1.1"
}

variable "controllers_spec" {
  type = object({
    cpu = number
    memory = number
    disk = number
  })
  default = {
    cpu = 4
    memory = 12288
    disk = 100
  }
}

variable "controllers_count" {
  type = number
  default = 1
}

variable "controllers_ip" {
  type = list(string)
  default = [
    "192.168.1.10"
  ]
}

locals {
  controller = [
    for i in range(var.controllers_count) : {
      name = "talab-m${i + 1}"
      node = var.node_name
      tags = [ "talab", "controller+worker", "talos" ]
      cpu = var.controllers_spec.cpu
      memory = var.controllers_spec.memory
      disk = var.controllers_spec.disk
      ipv4 = var.controllers_ip[i]
    }
  ]
}
