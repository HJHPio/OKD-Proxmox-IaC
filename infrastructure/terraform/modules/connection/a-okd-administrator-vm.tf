resource "proxmox_vm_qemu" "okd-administrator-vm" {
    target_node = var.proxmox_node_name
    count       = 1
    clone       = "${var.centos_template_name}"
    name        = format("okd4-administrator-%02d", count.index)
    desc        = "CentOS - for administrating OKD"
    vmid        = tonumber(var.centos_template_id) + 1

    memory      = 1024 * 6
    cores       = 8
    sockets     = 1
    vcpus       = 0
    cpu         = "host"
    numa        = true

    full_clone  = true
    os_type     = "cloud-init"
    bootdisk    = "scsi0"
    onboot      = true
    agent       = 1
    
    ciuser      = "${var.centos_template_user}"
    cipassword  = "${var.centos_template_password}"
    sshkeys     = file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")
    ipconfig0   = "ip=${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
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

    vga {
        type = "std"
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
                    size = 50
                }
            }
        }
    }
}

resource "null_resource" "configure_okd_administrator_vm" {
    depends_on                          = [
        proxmox_vm_qemu.okd-administrator-vm,
    ]
    count                               = 1

    provisioner "local-exec" {
        # (possible extension) TODO: [Update to use qm check state command instead of waiting 90s]
        command                         = <<EOT
        echo "Waiting 60s to cloudinit vm of ${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix}..." 
        sleep 60
        ssh-keygen -R ${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix} || true
        echo "Waiting for VM to be reachable via jump host on ${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix}..."
        for i in {1..18}; do
            if ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${var.centos_template_user}@${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix} true; then
                echo "VM is reachable via Proxmox jump host"
                break
            fi
            echo "Waiting for VM..."
            sleep 10
        done

        echo "Starting ansible-playbook using ProxyJump through Proxmox on ${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix}..."
        ansible-playbook -vv ${path.module}/../../ansible/configure_okd_administrator.yml \
            -i "${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix},"
        echo "Ansible playbook finished on ${var.okd_net_ip_addresses_prefix}.${var.okd_admin_vm_ip_suffix}."
        EOT
        
        environment = {
            ANSIBLE_HOST_KEY_CHECKING = "False"
            ANSIBLE_USER              = "${var.centos_template_user}"
            ANSIBLE_SSH_COMMON_ARGS   = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url}  -o StrictHostKeyChecking=no"
        }
    }
}
