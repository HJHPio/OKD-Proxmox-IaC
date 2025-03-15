resource "proxmox_vm_qemu" "cloudinit-okd-nfs" {
    target_node = "pve"
    count       = 1
    clone       = "CentOS-S9-Cloud-CI-SSH"
    name        = "okd4-nfs"
    desc        = "Cloudinit OKD NFS CentOS Stream 9"
    vmid        = tonumber(var.okd_net_nfs_ip_suffix) + count.index

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
    
    ciuser      = "${var.nfs_user}"
    cipassword  = "${var.nfs_pass}"
    sshkeys     = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    ipconfig0   = "ip=${var.okd_net_ip_addresses_prefix}.${var.okd_net_nfs_ip_suffix}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
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
                    size = 200
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

        echo "Starting ansible-playbook to configure nfs server..."
        ssh-keygen -R ${self.ssh_host}
        ansible-playbook -vv ${path.module}/../../ansible/configure_nfs_server.yml \
            -i "${self.ssh_host},"
        echo "Ansible playbook on nfs server is finished."
        EOT
        # Set environment for ansible playbook
        environment = {
          ANSIBLE_HOST_KEY_CHECKING   = "False",
          SSH_PUBLIC_KEY              = abspath("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key"),
          SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
          ANSIBLE_USER                = "${var.nfs_user}",
          API_IP                      = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_manager_ip_suffix}",
          PRIMARY_IPS                 = "${var.primary_ips_str}",
          COMPUTE_IPS                 = "${var.compute_ips_str}",
          NETWORK_MASK                = "${var.okd_net_mask}",
          NFS_PATH                    = "${var.nfs_path}"
        }
    }
}