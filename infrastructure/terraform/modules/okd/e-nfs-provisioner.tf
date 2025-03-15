resource "null_resource" "configure_nfs_provisioner" {
  count = var.configure_nfs_provider ? 1 : 0
  depends_on = [null_resource.wait_for_bootstrap_to_finish]

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
        ${path.module}/../../ansible/configure_nfs_provisioner.yml
    EOT
    # Set environment for ansible playbook
    environment = {
      ANSIBLE_HOST_KEY_CHECKING   = "False",
      ANSIBLE_USER                = "${var.manager_user}"
      NFS_PROVIDER_VERSION        = "${var.nfs_provider_version}"
      NFS_IP                      = "${var.okd_net_ip_addresses_prefix}.${var.okd_net_nfs_ip_suffix}"
      NFS_PATH                    = "${var.nfs_path}"
    }
  }
}
