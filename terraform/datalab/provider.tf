terraform {
  backend "http" {
    address = "https://${var.state_host}/state/datalab"
    lock_address = "https://${var.state_host}/state/datalab/lock"
    unlock_address = "https://${var.state_host}/state/datalab/lock"
    lock_method = "POST"
    unlock_method = "DELETE"
    retry_wait_min = 5
  }
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  alias = "pve"
  endpoint = "https://${var.proxmox_host}:8006/"
  insecure = true
  ssh {
    agent = true
  }
}