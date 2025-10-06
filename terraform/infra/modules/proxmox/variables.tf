variable "github_user" {
  type = string
  default = "foo"
}

variable "project_name" {
  type = string
}

variable "datastore_id" {
  type = string
  default = "local"
}

variable "vm_datastore_id" {
  type = string
  default = "local-lvm"
}

variable "instances" {
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
}
