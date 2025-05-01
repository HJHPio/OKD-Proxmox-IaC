locals {
  router_primary_id = var.router_template_id + 1
}

resource "proxmox_vm_qemu" "opnsense-router-okd" {
  count       = 1
  target_node = var.proxmox_node_name

  clone       = var.router_template_name
  name        = format("okd4-router-%02d", 0)
  desc        = "OPNsense Router for OKD"
  vmid        = local.router_primary_id

  memory      = 1024 * 2
  cores       = 2
  sockets     = 1
  vcpus       = 0
  cpu         = "host"
  numa        = true

  full_clone  = true
  bootdisk    = "scsi0"
  onboot      = true
  agent       = 0
  skip_ipv6   = true
  vm_state    = "running"

  bios        = "seabios"

  network {
    bridge    = var.okd_internal_bridge   # LAN for OKD internal components network
    firewall  = true
    link_down = false
    model     = "virtio" 
    mtu       = 0 
    queues    = 0 
    rate      = 0 
    tag       = -1
  }

  network {
    bridge    = "vmbr0"                   # Default Proxmox Linux Bridge with internet connection
    firewall  = true
    link_down = false
    model     = "virtio" 
    mtu       = 0 
    queues    = 0 
    rate      = 0 
    tag       = -1
  }

  network {
    bridge    = "vmbr1111"                # OPNsense pfSync interface
    firewall  = true
    link_down = false
    model     = "virtio" 
    mtu       = 0 
    queues    = 0 
    rate      = 0 
    tag       = -1
  }

  serial {
    id = 0
    type = "socket"
  }

  scsihw = "virtio-scsi-single" 
  disks {
    scsi {
      scsi0 {
        disk {
          emulatessd  = true
          storage     = var.vm_storage_name
          size        = "10G"
        }
      }
      scsi1 {
        cdrom {
          iso        = "local:iso/opnsense_example_config.iso"
        }
      }
    }
  }
}

#################################################
#             Execute init script               #
#################################################
resource "null_resource" "execute_opnsense_router_init_script" {
  depends_on        = [
    proxmox_vm_qemu.opnsense-router-okd,
  ]
  count             = 1

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for VM ${local.router_primary_id} to be running...'",
      "for i in {1..30}; do qm status ${local.router_primary_id} | grep -q running && break || sleep 5; done",
      "qm status ${local.router_primary_id}",
      "echo 'Waiting 1.5min for VM ${local.router_primary_id} to boot'",
      "sleep 90",
      "echo 'Executing init script'",
      "/var/lib/vz/template/iso/tmp-configs/opnsense_scripts/opnsense_init_script.sh ${local.router_primary_id}",
      "echo 'Waiting for VM ${local.router_primary_id} to reboot...'",
      "for i in {1..30}; do qm status ${local.router_primary_id} | grep -q running && break || sleep 5; done",
      "echo 'Checking VM ${local.router_primary_id} status'",
      "qm status ${local.router_primary_id}",
    ]
    connection {
      type          = "ssh"
      host          = var.pm_ssh_url
      user          = var.pm_ssh_user
      password      = var.pm_ssh_password 
    }
  }
}
#################################################
