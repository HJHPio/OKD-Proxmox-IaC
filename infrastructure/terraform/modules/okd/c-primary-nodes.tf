
data "ct_config" "primary_customized_ignition" {
  strict  = true
  count   = var.primary_count
  content = templatefile("${path.module}/../../ansible/files/configs/vm_customized_ignition.yaml.tftpl", {
    merge_ignition_source = "http://${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}:8080/okd4/master.ign"
    ssh_admin_username    = "core"
    ssh_admin_pass_hash   = "${var.ssh_admin_pass_hash}"
    ssh_admin_public_key  = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    hostname              = format("okd4-primary-%02d", count.index)
    cluster_domain_name   = "ownlab-okd4.hjhp.io"
    network_iname         = "ens18"
    network_ip            = format(
      "%s.%d",
      var.okd_net_ip_addresses_prefix,
      var.primary_initial_ip_suffix + count.index
    )
    network_address       = format(
      "%s.%d/%s",
      var.okd_net_ip_addresses_prefix,
      var.primary_initial_ip_suffix + count.index,
      var.okd_net_mask
    )
    network_gateway       = "${var.okd_net_gateway}"
    network_dns           = ["${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}"]
    network_mask          = "${var.okd_net_mask}"
    inactive_version      = "${var.okd_fcos_version}"
    inactive_digest       = "${var.okd_fcos_digest}"
  })
}

resource "proxmox_vm_qemu" "cloudinit-okd-primary" {
  depends_on  = [proxmox_vm_qemu.cloudinit-okd-bootstrap]

  target_node = "pve"
  count       = var.primary_count
  clone       = "FCOS-39-Clean-QCOW2"
  name        = format("okd4-primary-%02d", count.index)
  desc        = "Cloudinit OKD Primary FCOS using FCOS-39-Clean-QCOW2 qcow2 format image"
  vmid        = tonumber(var.primary_initial_ip_suffix) + count.index

  memory      = 1024 * 16
  cores       = 2
  sockets     = 2
  vcpus       = 0
  cpu         = "host"
  numa        = true

  full_clone  = true
  bootdisk    = "scsi0"
  onboot      = true
  agent       = 1
  skip_ipv6   = true

  bios        = "seabios"

  nameserver  = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}"
  network {
     bridge    = "vmbr0"
     firewall  = false
     link_down = false
     model     = "virtio" 
     mtu       = 0 
     queues    = 0 
     rate      = 0 
     tag       = -1
   }

  args = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.primary_customized_ignition[count.index].rendered, ",", ",,")}'"

  scsihw = "virtio-scsi-single" 
  disks {
    scsi {
      scsi0 {
        disk {
          emulatessd  = true
          storage     = "big-data"
          size        = 50 # TODO: configurable
        }
      }
    }
  }

}
