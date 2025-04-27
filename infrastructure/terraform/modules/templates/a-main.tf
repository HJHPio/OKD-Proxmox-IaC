#################################################
# Copy proxmox script for vm template creation  #
#################################################
resource "null_resource" "copy_proxmox_script_for_vm_template_creation" {
  count             = 1
  provisioner "remote-exec" {
    inline          = [
      "mkdir -p ~/proxmox-scripts",
      "echo '${file("${path.module}/../../ansible/files/secrets/ssh-pub-keys.key")}' > ~/proxmox-scripts/ssh-pub-keys.key",
      "echo '${file("${path.module}/proxmox-scripts/createCustomizedTemplateVM.sh")}' > ~/proxmox-scripts/createCustomizedTemplateVM.sh", 
      "chmod +x ~/proxmox-scripts/createCustomizedTemplateVM.sh" 
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
