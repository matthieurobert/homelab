variable "project_name" {
  type = string
}

variable "instances" {
  type = list(object({
    name = string
    k8s_role = string
    username = string
    ip = string
  }))
}