resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  url = "https://cloud-images.ubuntu.com/noble/20251213/noble-server-cloudimg-amd64.img"
  file_name = "${var.project_name}-ubuntu-cloud-image.img"
  content_type = "iso"
  datastore_id = var.datastore_id
  node_name = var.instances[0].node
  overwrite = true
}

data "github_user" "current" {
    username = var.github_user
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = { for instance in var.instances : instance.name => instance }
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = each.value.node

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
    ${join("\n", [for val in data.github_user.current.ssh_keys : "        - ${val}"])}
        sudo: ALL=(ALL) NOPASSWD:ALL
    timezone: Europe/Paris
    runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools curl linux-modules-extra-$(uname -r)
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "${var.project_name}-${each.key}-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = { for instance in var.instances : instance.name => instance }
  name = each.value.name
  node_name = each.value.node
  tags = each.value.tags
  on_boot = true

  cpu {
    cores = each.value.cpu
    type = "x86-64-v3"
  }
  memory {
    dedicated = each.value.memory
  }
  agent {
    enabled = true
  }

  disk {
    interface = "virtio0"
    datastore_id = var.vm_datastore_id
    file_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    file_format = "raw"
    size = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = each.value.ipv4
      }
      ipv6 {
        address = each.value.ipv6
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }
}
