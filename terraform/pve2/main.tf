resource "proxmox_virtual_environment_download_file" "talos_image" {
  url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.11.1/nocloud-amd64.iso"
  file_name = "nocloud-amd64.iso"
  verify = false
  content_type = "iso"
  datastore_id = var.datastore_id
  node_name = var.node_name
}

resource "proxmox_virtual_environment_vm" "talab" {
  for_each = { for instance in local.controller : instance.name => instance }
  name = each.value.name
  node_name = each.value.node
  tags = each.value.tags
  on_boot = true

  cpu {
    cores = each.value.cpu
    type = var.cpu_type
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
    file_id = proxmox_virtual_environment_download_file.talos_image.id
    size = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = var.vm_datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ipv4}/24"
        gateway = "${var.gateway_ip}"
      }
    }
    dns {
      servers = ["8.8.8.8", "8.8.4.4", "100.100.100.100"]
    }
  }
}

resource "talos_machine_secrets" "talab" {}

data "talos_machine_configuration" "talab" {
  depends_on = [ proxmox_virtual_environment_vm.talab ]
  cluster_name     = "talab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.controller[0].ipv4}:6443"
  machine_secrets  = talos_machine_secrets.talab.machine_secrets
}

resource "talos_machine_configuration_apply" "talab" {
  client_configuration        = talos_machine_secrets.talab.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talab.machine_configuration
  node = "${local.controller[0].ipv4}"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          # https://www.talos.dev/v1.10/talos-guides/install/virtualized-platforms/proxmox/#generate-machine-configurations
          disk = "/dev/vda"
          image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.1"
        }
        kubelet = {
          # https://www.talos.dev/v1.10/kubernetes-guides/configuration/deploy-metrics-server/
          extraArgs = {
            rotate-server-certificates = true
          }
        }
        nodeLabels = {
          "topology.kubernetes.io/region" = "kome"
          "topology.kubernetes.io/zone" = "${var.node_name}"
        }
      }
      # https://www.talos.dev/v1.10/kubernetes-guides/configuration/deploy-metrics-server/
      cluster = {
        extraManifests = [
          "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
          "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
        ]
        # https://www.talos.dev/v1.10/talos-guides/howto/workers-on-controlplane/
        allowSchedulingOnControlPlanes = true
      }
    })
  ]
}

resource "talos_machine_bootstrap" "talab" {
  depends_on = [
    talos_machine_configuration_apply.talab
  ]
  node = "${local.controller[0].ipv4}"
  client_configuration = talos_machine_secrets.talab.client_configuration
}

resource "talos_cluster_kubeconfig" "talab" {
  depends_on = [
    talos_machine_bootstrap.talab
  ]
  client_configuration = talos_machine_secrets.talab.client_configuration
  node = "${local.controller[0].ipv4}"
}
