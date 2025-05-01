#################################################
#          Creating CentOS VM template          #
#################################################
resource "null_resource" "create_centos_template" {
  depends_on        = [
    null_resource.copy_proxmox_script_for_vm_template_creation,
  ]
  count             = var.centos_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline          = [
      "~/proxmox-scripts/createCustomizedTemplateVM.sh --image-file '${var.centos_image_file}' --image-url '${var.centos_image_url}' --template-id '${var.centos_template_id}' --template-storage-name '${var.vm_storage_name}' --template-pass '${var.centos_template_password}' --template-user '${var.centos_template_user}' --template-name '${var.centos_template_name}' ${var.centos_additional_flags}",
    ]
    connection {
      type          = "ssh"
      host          = var.pm_ssh_url
      user          = var.pm_ssh_user
      password      = var.pm_ssh_password 
    }
  }

}
#################################################
