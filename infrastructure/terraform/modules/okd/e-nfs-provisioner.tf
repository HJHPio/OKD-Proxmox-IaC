resource "null_resource" "configure_nfs_provisioner" {
  depends_on                      = [
    null_resource.wait_for_bootstrap_to_finish,
  ]
  count                           = var.configure_nfs_provider ? 1 : 0

  provisioner "local-exec" {
    command                       = <<EOT
        echo "Waiting for VM ${var.lb_vip} to be reachable via Proxmox jump..."
        for i in {1..20}; do
            ssh -o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} \
                -o ConnectTimeout=5 \
                -o StrictHostKeyChecking=no \
                ${var.manager_user}@${var.lb_vip} "echo up" && break
            echo "Still waiting..."
            sleep 10
        done
        echo "Starting ansible-playbook for VM ${var.lb_vip}..."
      ansible-playbook -i "${var.lb_vip}," \
        --private-key ${path.module}/../../ansible/files/secrets/ssh-priv-key.key \
        ${path.module}/../../ansible/configure_nfs_provisioner.yml
        echo "Finished ansible-playbook for VM ${var.lb_vip}."
    EOT
    
    environment                   = {
      ANSIBLE_SSH_COMMON_ARGS     = "-o ProxyJump=${var.pm_ssh_user}@${var.pm_ssh_url} -o StrictHostKeyChecking=no",
      ANSIBLE_HOST_KEY_CHECKING   = "False",
      ANSIBLE_USER                = "${var.manager_user}"
      NFS_PROVIDER_VERSION        = "${var.nfs_provider_version}"
      NFS_IP                      = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_nfs_ip_suffix}"
      NFS_PATH                    = "${var.nfs_path}"
    }
  }
}
