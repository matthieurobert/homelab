terraform {
  backend "http" {
    address = "https://${var.state_host}/state/pve"
    lock_address = "https://${var.state_host}/state/pve/lock"
    unlock_address = "https://${var.state_host}/state/pve/lock"
    lock_method = "POST"
    unlock_method = "DELETE"
    retry_wait_min = 5
  }

  required_providers {
    proxmox = {
        source = "bpg/proxmox"
        version = "0.83.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
  insecure = true
  ssh {
    agent = true
  }
}