terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    github = {
      source = "integrations/github"
      version = "6.6.0"
    }
  }
}