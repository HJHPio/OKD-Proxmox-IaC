#################################################
#    Creating OPNsense Router VM template       #
#################################################
resource "null_resource" "create_opnsense_router_template" {
  depends_on        = [
    null_resource.copy_proxmox_script_for_vm_template_creation,
  ]
  count             = var.router_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline = [
      "~/proxmox-scripts/createCustomizedTemplateVM.sh --image-file '${var.router_image_file}' --image-url '${var.router_image_url}' --template-id '${var.router_template_id}' --template-name '${var.router_template_name}' --template-storage-name '${var.vm_storage_name}' ${var.router_additional_flags}"
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

#################################################
#  Creating OPNsense Router Configuration disc  #
#################################################
locals {
  opnsense_config_b64 = base64encode(templatefile("${path.module}/../../ansible/files/configs/opnsense_example_config.xml.tftpl", {
  }))
}
resource "null_resource" "create_opnsense_router_config_disk" {
  count             = var.router_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/vz/template/iso/tmp-configs/opnsense_example",
      "echo '${local.opnsense_config_b64}' | base64 -d > /var/lib/vz/template/iso/tmp-configs/opnsense_example/config.xml",
      "mkisofs -o /var/lib/vz/template/iso/opnsense_example_config.iso -V OPNCONF /var/lib/vz/template/iso/tmp-configs/opnsense_example",
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

#################################################
#  Creating Backup Router Configuration disc    #
#################################################
locals {
  opnsense_backup_config_b64 = base64encode(templatefile("${path.module}/../../ansible/files/configs/opnsense_example_backup_config.xml.tftpl", {
    # (possible extension) TODO: add placeholders overrides for: EXT Connection IP, Password Hash...
  }))
}
resource "null_resource" "create_backup_router_config_disk" {
  count             = var.router_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/vz/template/iso/tmp-configs/opnsense_example_backup",
      "echo '${local.opnsense_backup_config_b64}' | base64 -d > /var/lib/vz/template/iso/tmp-configs/opnsense_example_backup/config.xml",
      "mkisofs -o /var/lib/vz/template/iso/opnsense_example_backup_config.iso -V OPNCONF /var/lib/vz/template/iso/tmp-configs/opnsense_example_backup",
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

#################################################
#  Copy OPNsense Init Script                    #
#################################################
locals {
  opnsense_init_script = base64encode(file("${path.module}/../../ansible/files/scripts/opnsense_sendkey.sh"))
}
resource "null_resource" "create_opnsense_router_init_script" {
  count             = var.router_skip_tpl_creation ? 0 : 1

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/vz/template/iso/tmp-configs/opnsense_scripts",
      "echo '${local.opnsense_init_script}' | base64 -d > /var/lib/vz/template/iso/tmp-configs/opnsense_scripts/opnsense_init_script.sh",
      "chmod +x /var/lib/vz/template/iso/tmp-configs/opnsense_scripts/opnsense_init_script.sh",
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
