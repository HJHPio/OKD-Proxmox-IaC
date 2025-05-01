
data "ct_config" "bootstrap_customized_ignition" {
  strict                  = true
  count                   = 1
  content                 = templatefile("${path.module}/../../ansible/files/configs/vm_customized_ignition.yaml.tftpl", {
    merge_ignition_source = "http://${var.lb_vip}:8080/${var.okd_cluster_prefix}/bootstrap.ign"
    ssh_admin_username    = "core"
    ssh_admin_pass_hash   = "${var.ssh_admin_pass_hash}"
    ssh_admin_public_key  = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    hostname              = format("okd4-bootstrap-%02d", count.index)
    cluster_domain_name   = "${var.okd_cluster_subdomain}.${var.okd_cluster_domain}"
    network_iname         = "ens18"
    network_address       = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}/${var.okd_net_mask}"
    network_ip            = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}"
    network_gateway       = "${var.okd_net_gateway}"
    network_dns           = ["${var.lb_vip}"]
    network_mask          = "${var.okd_net_mask}"
    inactive_version      = "${var.okd_fcos_version}"
    inactive_digest       = "${var.okd_fcos_digest}"
  })
}

resource "proxmox_vm_qemu" "cloudinit-okd-bootstrap" {
  depends_on  =  [
    proxmox_vm_qemu.cloudinit-okd-manager,
  ]

  target_node = var.proxmox_node_name
  count       = 1
  clone       = "${var.scos_template_name}"
  name        = format("okd4-bootstrap-%02d", count.index)
  desc        = "Cloudinit OKD Bootstrap"
  vmid        = tonumber(var.scos_template_id) + tonumber(var.okd_net_bootstrap_ip_suffix) + count.index

  memory      = 1024 * 14
  cores       = 4
  sockets     = 1
  vcpus       = 0
  cpu         = "host"
  numa        = true

  full_clone  = true
  bootdisk    = "scsi0"
  onboot      = false
  agent       = 1
  skip_ipv6   = true

  bios        = "seabios"
  vm_state    = "${var.bootstrap_node_state}"

  network {
     bridge    = var.okd_internal_bridge
     firewall  = false
     link_down = false
     model     = "virtio" 
     mtu       = 0 
     queues    = 0 
     rate      = 0 
     tag       = -1
   }

  args = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.bootstrap_customized_ignition[count.index].rendered, ",", ",,")}'"

  scsihw = "virtio-scsi-single" 
  disks {
    scsi {
      scsi0 {
        disk {
          emulatessd  = true
          storage     = var.vm_storage_name
          size        = var.okd_default_node_disk_size
        }
      }
    }
  }

}