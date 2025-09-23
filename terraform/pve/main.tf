resource "proxmox_virtual_environment_vm" "haos" {
  name = "haos"
  node_name = "pve"
  tags = [
    "proxmox-helper-scripts",
    "terraform",
  ]
  bios = "ovmf"

  cpu {
    cores = 2
    type = "host"
  }
  memory {
    dedicated = 2048
  }
  agent {
    enabled = true
  }
  disk {
    interface = "scsi0"
    datastore_id = "local-lvm"
    file_format = "raw"
    size = 32
    ssd = true
    cache = "writethrough"
    discard = "on"
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format = "raw"
    pre_enrolled_keys = false
    type = "4m"
  }

  usb {
    host = "1a86:55d4"
  }

  operating_system {
    type = "l26"
  }

  tablet_device = false

  network_device {
    bridge = "vmbr0"
  }
}