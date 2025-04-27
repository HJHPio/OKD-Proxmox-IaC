#################################################
#          Creating SCOS VM template            #
#################################################
resource "null_resource" "create_scos_template" {
  depends_on        = [
    null_resource.copy_proxmox_script_for_vm_template_creation,
  ]
  count             = var.scos_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline          = [
      "~/proxmox-scripts/createCustomizedTemplateVM.sh --image-file '${var.scos_image_file}' --image-url '${var.scos_image_url}' --template-id '${var.scos_template_id}' --template-name '${var.scos_template_name}' --template-storage-name '${var.vm_storage_name}' ${var.scos_additional_flags}"
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
