locals {
    nfs_vip            = format(
      "%s.%d",
      var.okd_net_ip_addresses_prefix,
      var.okd_net_nfs_ip_suffix
    )
    nfs0_ip            = format(
      "%s.%d",
      var.okd_net_ip_addresses_prefix,
      var.okd_net_nfs_ip_suffix + 1
    )
    nfs1_ip            = format(
      "%s.%d",
      var.okd_net_ip_addresses_prefix,
      var.okd_net_nfs_ip_suffix + 2
    )
    nfs0_ipconfig       = format (
        "ip=${local.nfs0_ip}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
    )
    nfs1_ipconfig       = format (
        "ip=${local.nfs1_ip}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
    )
}


resource "proxmox_vm_qemu" "cloudinit-okd-nfs" {
    target_node = var.proxmox_node_name
    count       = 2
    clone       = var.centos_template_name
    name        = format("okd4-nfs-%02d", count.index)
    desc        = "CentOS NFS Server"
    vmid        = tonumber(var.centos_template_id) + tonumber(var.okd_net_ip_nfs_infix)*100 + count.index + 1

    memory      = 1024 * 4
    cores       = 4
    sockets     = 1
    vcpus       = 0
    cpu         = "host"
    numa        = true

    full_clone  = true
    os_type     = "cloud-init"
    bootdisk    = "scsi0"
    onboot      = true
    agent       = 1
    
    ciuser      = "${var.nfs_user}"
    cipassword  = "${var.nfs_pass}"
    sshkeys     = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    ipconfig0   = count.index == 0 ? local.nfs0_ipconfig : local.nfs1_ipconfig
    nameserver  = "${var.okd_net_gateway}"

    bios        = "seabios"

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

    scsihw   = "virtio-scsi-single" 
    disks {
        ide {
            ide2 {
                cloudinit {
                  storage = var.vm_storage_name
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    storage = var.vm_storage_name
                    size    = 10
                }
            }
            scsi1 {
                disk {
                    storage = var.vm_storage_name
                    size    = 200
                }
            }
        }
    }

    provisioner "local-exec" {
        # (possible extension) TODO: add waiting for "Finished Cloud-init final Stage."
        command = <<EOT
        sleep 30
        ssh-keygen -R ${self.ssh_host} || true
        echo "Waiting for VM ${self.ssh_host} to be reachable via Proxmox jump..."
        for i in {1..20}; do
            ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} \
                -o ConnectTimeout=5 \
                -o StrictHostKeyChecking=no \
                ${var.nfs_user}@${self.ssh_host} "echo up" && break
            echo "Still waiting..."
            sleep 10
        done

        echo "Starting ansible-playbook for VM ${self.ssh_host}..."
        ansible-playbook -vv ${path.module}/../../ansible/configure_nfs_server.yml \
            -i "${self.ssh_host},"
        echo "Ansible playbook for VM ${self.ssh_host} is finished."
        EOT
        # Set environment for ansible playbook
        environment = {
          ANSIBLE_SSH_COMMON_ARGS     = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no",
          ANSIBLE_HOST_KEY_CHECKING   = "False",
          SSH_PUBLIC_KEY              = abspath("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key"),
          SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
          ANSIBLE_USER                = "${var.nfs_user}",
          API_IP                      = "${var.okd_net_ip_main_prefix}.${var.okd_net_ip_lb_infix}.${var.okd_net_ip_lb_vip_suffix}",
          PRIMARY_IPS                 = "${var.primary_ips_str}",
          COMPUTE_IPS                 = "${var.compute_ips_str}",
          NETWORK_MASK                = "${var.okd_net_mask}",
          NFS_PATH                    = "${var.nfs_path}",
          NFS_VIP                     = "${local.nfs_vip}",
          NFS0_IP                     = "${local.nfs0_ip}",
          NFS1_IP                     = "${local.nfs1_ip}",
          PACEMAKER_CLUSTER_PASS      = "${var.pacemaker_cluster_pass}",
          PRIMARY_NFS                 = count.index == 0,
        }
    }
}
