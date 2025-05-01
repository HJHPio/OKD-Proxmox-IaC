resource "proxmox_vm_qemu" "cloudinit-okd-manager" {
    target_node = var.proxmox_node_name
    count       = 2
    clone       = var.centos_template_name
    name        = format("okd4-lb-%02d", count.index)
    desc        = "CentOS OKD Load Balancer and manager node"
    vmid        = tonumber(var.centos_template_id) + tonumber(var.okd_net_ip_lb_infix)*100 + 1 + count.index

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
    
    ciuser      = "${var.manager_user}"
    cipassword  = "${var.manager_pass}"
    sshkeys     = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    ipconfig0   = count.index == 0 ? var.lb00_ipconfig : var.lb01_ipconfig
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
                    size    = var.okd_default_node_disk_size
                }
            }
        }
    }

    provisioner "local-exec" {
        command                       = <<EOT
            sleep 30
            ssh-keygen -R ${self.ssh_host} || true
            echo "Waiting for VM ${self.ssh_host} to be reachable via Proxmox jump..."
            for i in {1..20}; do
                ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} \
                    -o ConnectTimeout=5 \
                    -o StrictHostKeyChecking=no \
                    ${var.manager_user}@${self.ssh_host} "echo up" && break
                echo "Still waiting..."
                sleep 10
            done
            echo "Starting ansible-playbook for VM ${self.ssh_host}..."
            ssh-keygen -R ${self.ssh_host}
            ansible-playbook -vv ${path.module}/../../ansible/configure_okd_lb.yml \
                -i "${self.ssh_host},"
            echo "Finished ansible-playbook for VM ${self.ssh_host}."
        EOT
        # Set environment for ansible playbook
        environment                   = {
          ANSIBLE_SSH_COMMON_ARGS     = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no",
          ANSIBLE_HOST_KEY_CHECKING   = "False",
          OKD_SUBDOMAIN               = var.okd_cluster_subdomain
          OKD_DOMAIN                  = var.okd_cluster_domain
          OKD_CLUSTER_NAME_PREFIX     = var.okd_cluster_prefix
          SSH_PUBLIC_KEY              = abspath("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key"),
          SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
          PULL_SECRET_FILE            = abspath("${path.module}/../../ansible/files/secrets/fake-pull-secret.txt"),
          ANSIBLE_USER                = "${var.manager_user}",
          OKD_VERSION                 = "${var.okd_version}",
          CUSTOM_DNS                  = "${var.custom_dns}",
          API_IP                      = "${var.lb_vip}",
          BOOTSTRAP_IP                = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}",
          PRIMARY_IPS                 = var.primary_ips_str,
          COMPUTE_IPS                 = var.compute_ips_str,
          PRIMARY_NODE                = count.index == 0,
          LB_VIP                      = var.lb_vip,
          LB0_IP                      = var.lb00_ip,
          LB1_IP                      = var.lb01_ip,
          PACEMAKER_CLUSTER_PASS      = "${var.pacemaker_cluster_pass}",
          NETWORK_MASK                = var.okd_net_mask,
        }
    }
}

resource "null_resource" "wait_for_bootstrap_to_finish" {
  depends_on                      = [proxmox_vm_qemu.cloudinit-okd-bootstrap]

  provisioner "local-exec" {
    command                       = <<EOT
        echo "Waiting for VM ${var.lb00_ip} to be reachable via Proxmox jump..."
        for i in {1..20}; do
            ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} \
                -o ConnectTimeout=5 \
                -o StrictHostKeyChecking=no \
                ${var.manager_user}@${var.lb00_ip} "echo up" && break
            echo "Still waiting..."
            sleep 10
        done
        echo "Starting ansible-playbook for VM ${var.lb00_ip}..."
        ansible-playbook -i "${var.lb00_ip}," \
            --private-key ${path.module}/../../ansible/files/secrets/ssh-priv-key.key \
            ${path.module}/../../ansible/wait_for_bootstrap_to_finish.yml
        echo "Finished ansible-playbook for VM ${var.lb00_ip}."
    EOT
    # Set environment for ansible playbook
    environment = {
      ANSIBLE_SSH_COMMON_ARGS     = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no",
      ANSIBLE_HOST_KEY_CHECKING   = "False",
      ANSIBLE_USER                = "${var.manager_user}"
      BOOTSTRAP_IP                = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_bootstrap_ip_suffix}"
      SSH_PRIVATE_KEY             = abspath("${path.module}/../../ansible/files/secrets/ssh-priv-key.key"),
      TF_VARS_PATH                = abspath("${path.module}/../../terraform.tfvars"),
      KUBEADMIN_PASS_OUTPUT_PATH  = abspath("${path.module}/../../ansible/files/secrets/kubadmin-pass.pass")
    }
  }
}

resource "null_resource" "copy_kubeconfig_on_lb01" {
  depends_on                      = [null_resource.wait_for_bootstrap_to_finish]

  provisioner "local-exec" {
    command                       = <<EOT
        echo "Waiting for VM ${var.lb01_ip} to be reachable via Proxmox jump..."
        ssh-keygen -R ${var.lb01_ip}
        for i in {1..20}; do
            ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} \
                -o ConnectTimeout=5 \
                -o StrictHostKeyChecking=no \
                ${var.manager_user}@${var.lb01_ip} "echo up" && break
            echo "Still waiting..."
            sleep 10
        done
        echo "Starting ansible-playbook for VM ${var.lb01_ip}..."
        ansible-playbook -i "${var.lb01_ip}," \
            --private-key ${path.module}/../../ansible/files/secrets/ssh-priv-key.key \
            ${path.module}/../../ansible/copy_kubeconfig_on_lb01.yml
        echo "Finished ansible-playbook for VM ${var.lb01_ip}."
    EOT
    # Set environment for ansible playbook
    environment = {
      ANSIBLE_SSH_COMMON_ARGS     = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no",
      ANSIBLE_HOST_KEY_CHECKING   = "False",
      ANSIBLE_USER                = "${var.manager_user}"
    }
  }
}
