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
          PRIMARY_IPS                 = var.primary_ips_str,
          COMPUTE_IPS                 = var.compute_ips_str,
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
