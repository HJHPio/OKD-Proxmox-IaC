locals {
  primary_ips = [
    for i in range(var.primary_count) :
    format("%s.%d", var.okd_net_ip_addresses_prefix, var.primary_initial_ip_suffix + i)
  ]

  compute_ips = [
    for i in range(var.compute_count) :
    format("%s.%d", var.okd_net_ip_addresses_prefix, var.compute_initial_ip_suffix + i)
  ]

  PRIMARY_IPS = join(", ", local.primary_ips)
  COMPUTE_IPS = join(", ", local.compute_ips)
}

resource "proxmox_vm_qemu" "cloudinit-okd-manager" {
    target_node = "pve"
    count       = 1
    clone       = "CentOS-S9-Cloud-CI-SSH"
    name        = format("okd4-manager-%02d", count.index)
    desc        = "Cloudinit OKD Manager CentOS Stream 9"
    vmid        = tonumber(var.okd_net_manager_ip_suffix) + count.index

    memory      = 1024 * 4
    cores       = 2
    sockets     = 2
    vcpus       = 0
    cpu         = "host"
    numa        = true

    full_clone  = true
    os_type     = "cloud-init"
    bootdisk    = "scsi0"
    onboot      = true
    agent       = 1
    
    ciuser      = "${var.manager_user}"
    cipassword  = "${var.manager_pass}"
    sshkeys     = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    ipconfig0   = "ip=${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
    nameserver  = "${var.okd_net_gateway}"

    bios        = "seabios"

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

    scsihw   = "virtio-scsi-single" 
    disks {
        ide {
            ide2 {
                cloudinit {
                  storage = "big-data"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    storage = "big-data"
                    size = 50
                }
            }
        }
    }

    provisioner "local-exec" {
        command = <<EOT
        echo "Waiting for VM to be reachable on IP: ${self.ssh_host} and port 22."
        for i in {1..10}; do
            if nc -zv ${self.ssh_host} 22; then
            echo "VM is reachable"
            break
            fi
            echo "Waiting for VM to be reachable..."
            sleep 10
        done

        echo "Starting ansible-playbook to configure manager node..."
        ssh-keygen -R ${self.ssh_host}
        ansible-playbook -vv ${path.module}/../../ansible/configure_okd_manager_node.yml \
            -i "${self.ssh_host},"
        echo "Ansible playbook on manager node is finished."
        EOT
        # Set environment for ansible playbook
        environment = {
          ANSIBLE_HOST_KEY_CHECKING   = "False",
          OKD_SUBDOMAIN               = "ownlab-okd4"
          OKD_DOMAIN                  = "hjhp.io"
          OKD_CLUSTER_NAME_PREFIX     = "okd4"
          SSH_PUBLIC_KEY              = abspath("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key"),
          SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
          PULL_SECRET_FILE            = abspath("${path.module}/../../ansible/files/secrets/fake-pull-secret.txt"),
          ANSIBLE_USER                = "${var.manager_user}",
          OKD_VERSION                 = "${var.okd_version}",
          CUSTOM_DNS                  = "${var.custom_dns}",
          API_IP                      = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}",
          BOOTSTRAP_IP                = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}",
          PRIMARY_IPS                 = local.PRIMARY_IPS,
          COMPUTE_IPS                 = local.COMPUTE_IPS
        }
    }
}

data "ct_config" "bootstrap_customized_ignition" {
  strict  = true
  count   = 1
  content = templatefile("${path.module}/../../ansible/files/configs/vm_customized_ignition.yaml.tftpl", {
    merge_ignition_source = "http://${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}:8080/okd4/bootstrap.ign"
    ssh_admin_username    = "core"
    ssh_admin_pass_hash   = "${var.ssh_admin_pass_hash}"
    ssh_admin_public_key  = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    hostname              = format("okd4-bootstrap-%02d", count.index)
    cluster_domain_name   = "ownlab-okd4.hjhp.io"
    network_iname         = "ens18"
    network_address       = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}/${var.okd_net_mask}"
    network_ip            = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}"
    network_gateway       = "${var.okd_net_gateway}"
    network_dns           = ["${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}"]
    network_mask          = "${var.okd_net_mask}"
    inactive_version      = "${var.okd_fcos_version}"
    inactive_digest       = "${var.okd_fcos_digest}"
  })
}

resource "proxmox_vm_qemu" "cloudinit-okd-bootstrap" {
  depends_on  =  [proxmox_vm_qemu.cloudinit-okd-manager]

  target_node = "pve"
  count       = 1
  clone       = "FCOS-39-Clean-QCOW2"
  name        = format("okd4-bootstrap-%02d", count.index)
  desc        = "Cloudinit OKD Bootstrap FCOS using FCOS-39-Clean-QCOW2 qcow2 format image"
  vmid        = tonumber(var.okd_net_bootstrap_ip_suffix) + count.index

  memory      = 1024 * 14
  cores       = 2
  sockets     = 2
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

  args = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.bootstrap_customized_ignition[count.index].rendered, ",", ",,")}'"

  scsihw = "virtio-scsi-single" 
  disks {
    scsi {
      scsi0 {
        disk {
          emulatessd  = true
          storage     = "big-data"
          size        = 50
        }
      }
    }
  }

}

resource "null_resource" "wait_for_bootstrap_to_finish" {
  depends_on = [proxmox_vm_qemu.cloudinit-okd-bootstrap]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for VM to be reachable on IP: ${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix} and port 22."
      for i in {1..10}; do
          if nc -zv ${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix} 22; then
          echo "VM is reachable"
          break
          fi
          echo "Waiting for VM to be reachable..."
          sleep 10
      done
      ansible-playbook -i "${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}," \
      --private-key ${path.module}/../../ansible/files/secrets/ssh-priv-key.key \
      ${path.module}/../../ansible/wait_for_bootstrap_to_finish.yml
    EOT
    # Set environment for ansible playbook
    environment = {
      ANSIBLE_HOST_KEY_CHECKING   = "False",
      ANSIBLE_USER                = "${var.manager_user}"
      BOOTSTRAP_IP                = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}"
      SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
      TF_VARS_PATH                = abspath("${path.module}/../../terraform.tfvars"),
      KUBEADMIN_PASS_OUTPUT_PATH  = abspath("${path.module}/../../ansible/files/secrets/kubadmin-pass.pass")
    }
  }
}

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
          size        = 50
        }
      }
    }
  }

}

data "ct_config" "compute_customized_ignition" {
  strict  = true
  count   = var.compute_count
  content = templatefile("${path.module}/../../ansible/files/configs/vm_customized_ignition.yaml.tftpl", {
    merge_ignition_source = "http://${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}:8080/okd4/worker.ign"
    ssh_admin_username    = "core"
    ssh_admin_pass_hash   = "${var.ssh_admin_pass_hash}"
    ssh_admin_public_key  = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    hostname              = format("okd4-compute-%02d", count.index)
    cluster_domain_name   = "ownlab-okd4.hjhp.io"
    network_iname         = "ens18"
    network_ip            = format(
      "%s.%d",
      var.okd_net_ip_addresses_prefix,
      var.compute_initial_ip_suffix + count.index
    )
    network_address       = format(
      "%s.%d/%s",
      var.okd_net_ip_addresses_prefix,
      var.compute_initial_ip_suffix + count.index,
      var.okd_net_mask
    )
    network_gateway       = "${var.okd_net_gateway}"
    network_dns           = ["${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}"]
    network_mask          = "${var.okd_net_mask}"
    inactive_version      = "${var.okd_fcos_version}"
    inactive_digest       = "${var.okd_fcos_digest}"
  })
}

resource "proxmox_vm_qemu" "cloudinit-okd-compute" {
  depends_on  = [proxmox_vm_qemu.cloudinit-okd-primary]

  target_node = "pve"
  count       = var.compute_count
  clone       = "FCOS-39-Clean-QCOW2"
  name        = format("okd4-compute-%02d", count.index)
  desc        = "Cloudinit OKD Compute FCOS using FCOS-39-Clean-QCOW2 qcow2 format image"
  vmid        = tonumber(var.compute_initial_ip_suffix) + count.index

  memory      = 1024 * 10
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

  args = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.compute_customized_ignition[count.index].rendered, ",", ",,")}'"

  scsihw = "virtio-scsi-single" 
  disks {
    scsi {
      scsi0 {
        disk {
          emulatessd  = true
          storage     = "big-data"
          size        = 50
        }
      }
    }
  }

}