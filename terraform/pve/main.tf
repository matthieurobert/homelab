resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  url = "https://cloud-images.ubuntu.com/noble/20250805/noble-server-cloudimg-amd64.img"
  file_name = "${var.project_name}-ubuntu-cloud-image.img"
  content_type = "iso"
  datastore_id = var.datastore_id
  node_name = "pve"
  overwrite = true
}

data "github_user" "current" {
    username = var.github_user
}

resource "proxmox_virtual_environment_file" "docker_cloud_config" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = "pve"

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
        - curl -fsSL https://get.docker.com -o get-docker.sh
        - sh get-docker.sh
        - mkdir -p /home/ubuntu/portainer
        - |
          cat > /home/ubuntu/portainer/docker-compose.yml << 'EOL'
          services:
            portainer:
              image: portainer/portainer-ce:latest
              container_name: portainer
              restart: unless-stopped
              ports:
                - "9000:9000"
                - "9443:9443"
              volumes:
                - /var/run/docker.sock:/var/run/docker.sock
                - portainer_data:/data
              security_opt:
                - no-new-privileges:true
          
          volumes:
            portainer_data:
          EOL
        - chown -R ubuntu:ubuntu /home/ubuntu/portainer
        - cd /home/ubuntu/portainer && sudo docker compose -p portainer up -d
        - sudo modprobe ch341
        - sudo reboot
    EOF

    file_name = "${var.project_name}-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "docker" {
  name = var.docker_instance.name
  node_name = var.docker_instance.node
  tags = var.docker_instance.tags
  on_boot = true

  cpu {
    cores = var.docker_instance.cpu
    type = "x86-64-v3"
  }
  memory {
    dedicated = var.docker_instance.memory
  }
  agent {
    enabled = true
  }

  disk {
    interface = "virtio0"
    datastore_id = var.vm_datastore_id
    file_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    file_format = "raw"
    size = var.docker_instance.disk
  }

  usb {
    host = "1a86:55d4"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = var.docker_instance.ipv4
      }
      ipv6 {
        address = var.docker_instance.ipv6
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.docker_cloud_config.id
  }
}
